module fnmadd_s(
    input clk,
    input resetn,
    input [31:0] rs1,
    input [31:0] rs2,
    input [31:0] rs3,
    output [31:0] out
);

wire [31:0] d0_out;
wire [31:0] d0_outn;
wire [31:0] rs3n;

assign d0_outn = {~d0_out[31], d0_out[30:0]};
assign rs3n = {~rs3[31], rs3[30:0]};

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
    .rs1(d0_outn),
    .rs2(rs3n),
    .out(out)
);

// Dump waves
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, fnmadd_s);
end

endmodule