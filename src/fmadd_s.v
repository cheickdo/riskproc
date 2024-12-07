module fmadd_s(
    input clk,
    input resetn,
    input [31:0] rs1,
    input [31:0] rs2,
    input [31:0] rs3,
    output [31:0] out
);

wire [31:0] d0_out;

//multiply1
fmul d0(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .out(d0_out)
);

//adder
fpadd d1(
    .clk(clk),
    .resetn(resetn),
    .rs1(d0_out),
    .rs2(rs3),
    .out(out)
);

// Dump waves
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, fmadd_s);
end

endmodule