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
        
        $dumpfile("dump.vcd");
        $dumpvars(2, memory);
    end

    always@(*) 
        //din = my_mem[realaddr];
        if (W) my_mem[ADDR] <= dout;
        else din = my_mem[realaddr];
    

endmodule