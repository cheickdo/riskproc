module issue_queue #(parameter DATA_WIDTH=32, parameter DEPTH=16, parameter FIELD_WIDTH=53) (
    input clk, resetn,
    input enq, deq,
    input [DATA_WIDTH-1:0] data_in,
    output reg [FIELD_WIDTH-1:0] data_out,
    output full, empty
);

//array including instruction and tags
reg [FIELD_WIDTH-1:0] queue [DEPTH];
reg [DEPTH-1:0] allocation;
reg [$clog2(DEPTH)-1:0] addr;
reg [FIELD_WIDTH-1:0] test;

//bit 36 of the queue is the allocation bit
always@(*) begin
    for (int i=0; i<DEPTH; i=i+1) begin
        allocation[i] = queue[i][16];
    end
end

//priority encoder logic for issue queue based on allocation bit to store instruction to unallocated entry, do not use break statement
generate
always@(*) begin
    for (int i=DEPTH-1; i>=0; i=i-1) begin
        if (allocation[i] == 0) begin
            addr = i;
        end
    end
    
    //assign test = queue[addr];
    test = queue[0];
end
endgenerate

always@(posedge clk) begin
    if (!resetn) begin
        //write 0 to all queue elements
        for (int i=0; i<DEPTH; i=i+1) begin
            queue[i] <= 0;
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
                queue[addr] <= {4'b0, data_in, 1'b1, 16'b0};
            end
        endcase
    end
end



initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, issue_queue);
end

endmodule