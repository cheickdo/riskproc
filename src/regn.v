module regn #(
    parameter n = 32
) (
    input wire [n-1:0] D,
    input wire resetn,
    input wire En,
    input wire clk,
    output reg [n-1:0] Q
);
  always @(posedge clk)
    if (!resetn) Q <= 0;
    else if (En) Q <= D;
endmodule