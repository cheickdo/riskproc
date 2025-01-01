module dispatcher #(parameter XLEN=32, parameter FIELD_WIDTH=109) (
    input clk, resetn,
    input enq_ifq,
    input deq_ifq,
    input [XLEN-1:0] data_in_ifq,
    input full_intalu, full_fpalu, full_agu,
    input alu_ready_i, fpalu_ready_i, agu_ready_i,
    input [XLEN:0] rs1_i, rs2_i, rd_i,
    output full_ifq, empty_ifq,
    output [4:0] rs1_sel, rs2_sel, rd_sel,
    output [XLEN:0] BusWires1, BusWires2,
    output alu_data_out_valid, fpalu_data_out_valid, agu_data_out_valid,
    output [FIELD_WIDTH-1:0] intalu_data_o, fpalu_data_o, agu_data_o
);

wire [6:0] opcode;
wire [XLEN-1:0] data_out_ifq;
wire [11:0] I_Imm, S_Imm;
wire [12:0] B_Imm;
//wire [9:0] J_Imm; //Not sure if this width is correct
wire [20:0] UJ_Imm;
wire [19:0] U_Imm; 

reg [1:0] queue_sel;
reg enq_intalu, enq_fpalu, enq_agu;
reg [XLEN-1:0] intalu_data_i, fpalu_data_i, agu_data_i;
reg [XLEN:0] rs1_o, rs2_o, rd_o, rs1_o_d, rs2_o_d, rd_o_d;

//Immediate values
assign I_Imm = data_out_ifq[31:20];
assign S_Imm = {data_out_ifq[31:25], data_out_ifq[11:7]};
assign B_Imm = {data_out_ifq[31], data_out_ifq[7], data_out_ifq[30:25], data_out_ifq[11:8], 1'b0}; //NOT CORRECT
assign UJ_Imm = {data_out_ifq[31], data_out_ifq[19:12], data_out_ifq[20], data_out_ifq[30:21], 1'b0};
assign U_Imm = {data_out_ifq[31:12]};


//opcode types
parameter R_type = 7'b0110011, I_type_1=7'b0000011, I_type_2 = 7'b0010011;
parameter SB_type = 7'b1100111, S_type = 7'b0100011, U_type = 7'b0110111, UJ_type=7'b1101111, U2_type = 7'b0010111, B_type = 7'b1100011;
parameter SYSTEM_type = 7'b1110011;
parameter FLW_type = 7'b0000111, FSW_type = 7'b0100111, FMADD_type = 7'b1000011, FMSUB_type = 7'b1000111,
    FNMSUB_type = 7'b1001011, FNMADD_type = 7'b1001111, F_type = 7'b1010011;

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
assign rd_sel = data_out_ifq[11:7];
assign funct3 = data_out_ifq[14:12];
assign rs1_sel  = data_out_ifq[19:15];
assign rs2_sel = data_out_ifq[24:20];
assign rs1_o = rs1_i;
assign rd_o = rd_i;

//case for immediate value instructions
always@(*)
    case (opcode) 
        I_type_1: rs2_o = {1'b0, {20{I_Imm[11]}},I_Imm}; 
        I_type_2: rs2_o = {1'b0, {20{I_Imm[11]}},I_Imm};
        S_type: rs2_o = {1'b0, 20'b0, S_Imm};
        UJ_type: rs2_o = {1'b0, {11{UJ_Imm[20]}},UJ_Imm};
        SB_type: rs2_o = {1'b0, {20{I_Imm[11]}},I_Imm};
        U_type: rs2_o = {1'b0, {12{U_Imm[19]}},U_Imm};
        U2_type: rs2_o = {1'b0, {12{U_Imm[19]}},U_Imm};
        FLW_type: rs2_o = {1'b0, {20{I_Imm[11]}},I_Imm};
        FSW_type: rs2_o = {1'b0, 20'b0, S_Imm};
        B_type: begin
            if ((funct3 == 3'b110) | (funct3 == 3'b111)) rs2_o = {1'b0, 19'b0, B_Imm};
            else rs2_o = {1'b0, {19{B_Imm[11]}}, B_Imm};
        end
        default: rs2_o = rs2_i;
    endcase


//Note: garbage in garbage out, correctness of opcode is assumed
always@(*) begin
    queue_sel = 2'b00;
    casez(opcode)
        7'b10?????: queue_sel = FPALU;
        7'b0?0????: queue_sel = AGU;
        default: queue_sel = INTALU;
    endcase
end

//check for immediate value instructiondata_in


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
                    rs1_o_d <= rs1_o;
                    rs2_o_d <= rs2_o;
                end
                FPALU: begin
                    enq_fpalu <= 1;
                    enq_intalu <= 0;
                    enq_agu <= 0;
                    fpalu_data_i <= data_out_ifq;
                    rs1_o_d <= rs1_o;
                    rs2_o_d <= rs2_o;
                end
                AGU: begin
                    enq_agu <= 1;
                    enq_intalu <= 0;
                    enq_fpalu <= 0;
                    agu_data_i <= data_out_ifq;
                    rs1_o_d <= rs1_o;
                    rs2_o_d <= rs2_o;
                end
                default: begin
                    enq_intalu <= 0;
                    enq_fpalu <= 0;
                    enq_agu <= 0;
                end
            endcase
            //deq_ifq <= 1;
        end
        else begin
            enq_intalu <= 0;
            enq_fpalu <= 0;
            enq_agu <= 0;
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
    .rs1_i(rs1_o_d),
    .rs2_i(rs2_o_d),
    .rd_i(rd_o),
    .data_out_valid(alu_data_out_valid),
    .full(),
    .empty()
);

// Dump waves
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(2, dispatcher);
end

endmodule

