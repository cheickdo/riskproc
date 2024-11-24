module counter (
    input clk,
    input resetn,
    input enable,
    output reg[XLEN-1:0] out
);
    parameter XLEN = 32;

    always@(posedge clk)
    if (!resetn)
        out <= 0;
    else if (enable)
        out <= out + 1;

endmodule