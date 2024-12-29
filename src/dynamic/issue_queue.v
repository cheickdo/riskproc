module issue_queue #(parameter DATA_WIDTH=32, parameter DEPTH=16, parameter FIELD_WIDTH=55) (
    input clk, resetn,
    input enq, deq,
    input ready_i,
    input [DATA_WIDTH-1:0] data_in,
    output reg [FIELD_WIDTH-1:0] data_out,
    output reg data_out_valid,
    output full, empty
);

/*

Allocation of queue
[54:51]: ID
[50:19]: Instruction
[18]: Allocation bit
[17:13]: operand1
[12]: operand1 ready
[11:7]: operand2
[6]: operand2 ready
[5:1]: destination
[0]: destination ready? <= not used or needed, should be tagged with dependant ID

*/

//array including instruction and tags
reg [FIELD_WIDTH-1:0] queue [DEPTH];
reg [DEPTH-1:0] allocation, operand1_ready, operand2_ready, destination_ready;
reg [$clog2(DEPTH)-1:0] addr_in, addr_out;
reg [FIELD_WIDTH-1:0] test;
reg [$clog2(DEPTH)-1:0] count;

wire all_ready;

assign all_ready = |(operand1_ready & operand2_ready);

//bit 18 of the queue is the allocation bit
always@(*) begin
    for (int i=0; i<DEPTH; i=i+1) begin
        allocation[i] = queue[i][18];
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
    test = queue[addr_in];
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
                    queue[addr_in] <= {4'b0, data_in, 1'b1, 16'b0};
                    count <= count + 1;
                end
            end
        endcase
    end
end

always@(posedge clk) begin
    if (!resetn) data_out_valid <= 0;
    else if (ready_i & !empty & all_ready) data_out_valid <= 1;
end

assign full = (count == DEPTH-1);
assign empty = (count == 0);

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, issue_queue);
end

endmodule