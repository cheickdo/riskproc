module fsgnj_s(
    input clk,
    input resetn,
    input [31:0] rs1,
    input [31:0] rs2,
    output reg [31:0] out
);

always@(*)
    out = {rs2[31], rs1[30:0]};

// Dump waves
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, fsgnj_s);
end
endmodule
