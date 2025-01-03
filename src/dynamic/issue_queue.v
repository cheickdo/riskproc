module issue_queue #(parameter DATA_WIDTH=32, parameter DEPTH=16, parameter FIELD_WIDTH=109) (
    input clk, resetn,
    input enq, deq,
    input ready_i,
    input [DATA_WIDTH:0] rs1_i, rs2_i, rd_i,
    input [4:0] rd_num_i, 
    input [DATA_WIDTH-1:0] data_in,
    input [ID_WIDTH-1:0] cdb_tag,
    input [DATA_WIDTH-1:0] cdb_data,
    input cdb_valid,
    output reg [FIELD_WIDTH-1:0] data_out,
    output reg data_out_valid,
    output full, empty
);

parameter ID_WIDTH = $clog2(DEPTH);

/*

Allocation of queue
[108:105]: ID
[104:73]: Instruction
[72]: Allocation bit
[71:40]: operand1
[39]: operand1 ready
[38:7]: operand2
[6]: operand2 ready
[5:1]: destination register number
[0]: destination ready? <= not used or needed, should be tagged with dependant ID

*/

//array including instruction and tags
reg [FIELD_WIDTH-1:0] queue [DEPTH];
reg [DEPTH-1:0] allocation, operand1_ready, operand2_ready, destination_ready;
reg [ID_WIDTH-1:0] addr_in, addr_out;
reg [FIELD_WIDTH-1:0] test;
reg [DATA_WIDTH-1:0] data_test;
reg [ID_WIDTH-1:0] count;

wire any_ready;
wire rs1_valid, rs2_valid;

assign any_ready = |(operand1_ready & operand2_ready);
assign rs1_valid = rs1_i[32];
assign rs2_valid = rs2_i[32];

//bit 72 of the queue is the allocation bit
always@(*) begin
    for (int i=0; i<DEPTH; i=i+1) begin
        allocation[i] = queue[i][72];
        operand1_ready[i] = queue[i][39];
        operand2_ready[i] = queue[i][6];
    end
end

//priority encoder logic for issue queue based on allocation bit to store instruction to unallocated entry
generate
always@(*) begin
    for (int i=DEPTH-1; i>=0; i=i-1) begin
        if (allocation[i] == 0) begin
            addr_in = i;
        end
    end
    
    //test to check if the priority encoder is working
    //test = queue[addr_in];
    //data_test = queue[addr_in][104:73];
end
endgenerate

//priority encoder logic for issue queue based on allocation bit to issue ready instruction to execution units
generate
always@(*) begin
    for (int i=DEPTH-1; i>=0; i=i-1) begin
        if ((allocation[i] == 1) & (operand1_ready[i] == 1) & (operand2_ready[i] == 1)) begin
            addr_out = i;
        end
    end
    
    data_out = queue[addr_out];
end
endgenerate

always@(posedge clk) begin
    if (!resetn) begin
        //write 0 to all queue elements
        for (int i=0; i<DEPTH; i=i+1) begin
            queue[i] <= 0;
        end
        count <= 0;
    end
    else if (cdb_valid) begin
        for (int i=0; i<DEPTH; i=i+1) begin
            if (queue[i][39] == 1'b0) begin //if operant not ready value in cdb will be the register number
                queue[i] <= {queue[i][108:73], 1'b0, queue[i][71:40], 1'b1, queue[i][38:7], 1'b1, queue[i][5:1], 1'b1};
            end
        end

        for (int i=0; i<DEPTH; i=i+1) begin
            if (queue[i][5:1] == cdb_tag) begin
                queue[i] <= {queue[i][108:73], 1'b0, queue[i][71:40], 1'b1, queue[i][38:7], 1'b1, queue[i][5:1], 1'b1};
            end
        end
    end
    else begin
        case({enq,deq})
            2'b00, 2'b11: begin
                //do nothing
            end
            2'b01: begin
                //dequeue
                //data_out <= queue[0];
                //for (int i=0; i<DEPTH-1; i=i+1) begin
                //    queue[i] <= queue[i+1];
                //end
                //queue[DEPTH-1] <= 0;
            end
            2'b10: begin
                //enqueue
                if (!full) begin
                    queue[addr_in] <= {addr_in, data_in[31:0], 1'b1, rs1_i[31:0], ~rs1_valid, rs2_i[31:0], ~rs2_valid, rd_num_i, 1'b0};
                    //queue[addr_in] <= {50{1'b1}};
                    count <= count + 1;
                end
            end
        endcase
    end
end

always@(posedge clk) begin
    if (!resetn) data_out_valid <= 0;
    else if (ready_i & !empty & any_ready) data_out_valid <= 1;
end

assign full = (count == DEPTH-1);
assign empty = (count == 0);

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, issue_queue);
end

endmodule