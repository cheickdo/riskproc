/*
Single Precision IEEE 754 floating point divider through Newton-Raphson iteration
    chk
*/
module fdiv(
    input clk,
    input resetn,
    input [31:0] rs1,
    input [31:0] rs2,
    output [31:0] out
);

wire [22:0] recip_m;
wire [7:0] recip_e;

wire s1, s2;
wire [7:0] e1, e2;
wire [22:0] m1, m2;

wire [31:0] reciprocal;
wire [31:0] in_reduced; 
wire [31:0] in_reducedx2;

wire [31:0] d0_out, d1_out, d2_out, d3_out, d4_out, d5_out, d6_out;
wire [31:0] d1_outn, d4_outn;
wire [31:0] const_two, const_init;

assign s1 = rs1[31];
assign s2 = rs2[31]; 
assign e1 = rs1[30:23];
assign e2 = rs2[30:23];
assign m1 = rs1[22:0];
assign m2 = rs2[22:0];

assign in_reduced = {1'b0, 8'h80, m2};
assign in_reducedx2 = {1'b0, 8'h81, m2};
assign in_reducedx2n = {~in_reducedx2[31],in_reducedx2[30:0]};
assign d1_outn = {~d1_out[31], d1_out[30:0]};
assign d4_outn = {~d4_out[31], d4_out[30:0]};
assign const_init = 32'h403A8241;
assign const_two =   32'h40000000;

assign recip_e = (in_reduced == 9'b100000000) ? 9'h102 - e2 : 9'h101 - e2;
assign reciprocal = {s2, recip_e, recip_m};

//subtract
fmul d0(
    .clk(clk),
    .resetn(resetn),
    .rs1(const_init),
    .rs2(in_reducedx2n),
    .out(d0_out)
);

//multiply1
fmul d1(
    .clk(clk),
    .resetn(resetn),
    .rs1(in_reduced),
    .rs2(d0_out),
    .out(d1_out)
);

//adder
fpadd d2(
    .clk(clk),
    .resetn(resetn),
    .rs1(const_two),
    .rs2(d1_outn),
    .out(d2_out)
);

//multiply2
fmul d3(
    .clk(clk),
    .resetn(resetn),
    .rs1(d0_out),
    .rs2(d2_out),
    .out(d3_out)
);

//multiply3
fmul d4(
    .clk(clk),
    .resetn(resetn),
    .rs1(in_reduced),
    .rs2(d3_out),
    .out(d4_out)
);

//adder
fpadd d5(
    .clk(clk),
    .resetn(resetn),
    .rs1(const_two),
    .rs2(d4_outn),
    .out(d5_out)
);

//multiply4
fmul d6(
    .clk(clk),
    .resetn(resetn),
    .rs1(d0_out),
    .rs2(d5_out),
    .out(d6_out)
);

//form output
fmul d7(
    .clk(clk),
    .resetn(resetn),
    .rs1(reciprocal),
    .rs2(rs1),
    .out(out)
);

// Dump waves
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, fdiv);
end

endmodule