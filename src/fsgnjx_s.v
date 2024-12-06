module fsgnjx_s(
    input clk,
    input resetn,
    input [31:0] rs1,
    input [31:0] rs2,
    output reg [31:0] out
);
wire sign_xor;
assign sign_xor = rs1[31] ^ rs2[31]; 

always@(*)
    out = {sign_xor, rs1[30:0]};

// Dump waves
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, fsgnjx_s);
end
endmodule
