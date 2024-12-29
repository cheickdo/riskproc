module dispatcher #(parameter XLEN=32, parameter FIELD_WIDTH=55) (
    input clk, resetn,
    input enq_ifq,
    input deq_ifq,
    input [XLEN-1:0] data_in_ifq,
    input full_intalu, full_fpalu, full_agu,
    input alu_ready_i, fpalu_ready_i, agu_ready_i,
    output full_ifq, empty_ifq,
    output [FIELD_WIDTH-1:0] intalu_data_o, fpalu_data_o, agu_data_o
);

wire [6:0] opcode;
wire [XLEN-1:0] data_out_ifq;

reg [1:0] queue_sel;
reg enq_intalu, enq_fpalu, enq_agu;
reg [XLEN-1:0] intalu_data_i, fpalu_data_i, agu_data_i;

parameter INTALU = 2'b00, FPALU = 2'b01, AGU = 2'b10;

//Instruction fetch queue
sync_fifo #(8, XLEN) ifq (
    .clk(clk),
    .resetn(resetn),
    .enq(enq_ifq),
    .deq(deq_ifq),
    .data_in(data_in_ifq),
    .data_out(data_out_ifq),
    .full(full_ifq),
    .empty(empty_ifq)
);

//address decoder for issue queues
//Integer & branch 0110011, 0010011, 1100011, 1101111, 1100111, 0110111, 0010111, 0110011
//Floating point 1010011, 1000011, 1000111, 1001011, 1001111
//Store & Loads 0000011, 0100011, 0000111, 0100111

assign opcode = data_out_ifq[6:0];

//Note: garbage in garbage out, correctness of opcode is assumed
always@(*) begin
    queue_sel = 2'b00;
    casez(opcode)
        7'b10?????: queue_sel = 2'b01;
        7'b0?0????: queue_sel = 2'b10;
        default: queue_sel = 2'b00;
    endcase
end

//state machine where instructions at front of queue are decoded and dispatched to one of 3 issue queues(based on opcodes)
always@(posedge clk) begin
    if(!resetn) begin
        enq_intalu <= 0;
        enq_fpalu <= 0;
        enq_agu <= 0;
    end
    else begin
        if(!empty_ifq & deq_ifq) begin
            case(queue_sel)
                INTALU: begin
                    enq_intalu <= 1;
                    enq_fpalu <= 0;
                    enq_agu <= 0;
                    intalu_data_i <= data_out_ifq;
                end
                FPALU: begin
                    enq_fpalu <= 1;
                    enq_intalu <= 0;
                    enq_agu <= 0;
                    fpalu_data_i <= data_out_ifq;
                end
                AGU: begin
                    enq_agu <= 1;
                    enq_intalu <= 0;
                    enq_fpalu <= 0;
                    agu_data_i <= data_out_ifq;
                end
                default: begin
                    enq_intalu <= 0;
                    enq_fpalu <= 0;
                    enq_agu <= 0;
                end
            endcase
            //deq_ifq <= 1;
        end
    end
end

//instantiate issue queues and send data to them
issue_queue int_q(
    .clk(clk),
    .resetn(resetn),
    .enq(enq_intalu),
    .deq(1'b0),
    .data_in(intalu_data_i),
    .data_out(intalu_data_o),
    .ready_i(alu_ready_i),
    .full(),
    .empty()
);

// Dump waves
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(2, dispatcher);
end

endmodule

