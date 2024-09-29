module memory
(
    input clk,
    input W,
    input [4:0] realaddr,
    input [31:0]dout,
    output reg[31:0] din
);
    reg [31:0] my_mem[0:255];

    initial begin
        my_mem[0] = 'b000000001000000000011;
        my_mem[1] = 1;
        my_mem[2] = 2;
        my_mem[3] = 3;
        
        $dumpfile("dump.vcd");
        $dumpvars(2, memory);
    end

    always@(posedge clk) 
        din = my_mem[0];
        //if (W) my_mem[ADDR] <= dout;
        //else out <= my_mem[ADDR];
    

endmodule