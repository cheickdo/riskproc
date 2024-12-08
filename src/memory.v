module memory
(
    input clk,
    input W,
    input [15:0] realaddr,
    input [31:0]dout,
    output reg[31:0] din
);
    reg [31:0] my_mem[0:65535]; //16 bits worth right now

    always@(*) 
        //din = my_mem[realaddr];
        if (W) my_mem[realaddr] <= dout;
        else din <= my_mem[realaddr];
    
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(1, memory);
    end


endmodule