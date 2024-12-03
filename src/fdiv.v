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

reg [31:0] cnt;

wire [31:0] reciprocal;
wire [31:0] in_reduced; 
wire [31:0] in_reducedx2, in_reducedx2n;

wire [31:0] d0_out, d1_out, d2_out, d3_out, d4_out, d5_out, d6_out, d7_out, d8_out;
wire [31:0] d0_outn, d2_outn, d4_outn, d5_outn;
wire [31:0] const_two, const_init;

wire [31:0] T1; //48/17
wire [31:0] T2; //32/17

assign s1 = rs1[31];
assign s2 = rs2[31]; 
assign e1 = rs1[30:23];
assign e2 = rs2[30:23];
assign m1 = rs1[22:0];
assign m2 = rs2[22:0];

assign in_reduced = {1'b0, 8'h7E, m2};
//assign in_reducedx2 = {1'b0, 8'h81, m2};
//assign in_reducedx2n = {~in_reducedx2[31],in_reducedx2[30:0]};
assign d0_outn = {~d0_out[31], d0_out[30:0]};
assign d2_outn = {~d2_out[31], d2_out[30:0]};
assign d5_outn = {~d5_out[31], d5_out[30:0]};

assign const_init = 32'h403A8241; //2.9142
assign const_two =   32'h40000000;
assign T1 = 32'h4034B4B5;
assign T2 = 32'h3FF0F0F1;

assign recip_m = d7_out[22:0];
assign recip_e = (in_reduced == 23'b00000000000000000000000) ? 254 - e2 : 253 - e2; //to verify
assign reciprocal = {s2, recip_e, recip_m};

//initialise a guess
fmul d0(
    .clk(clk),
    .resetn(resetn),
    .rs1(in_reduced),
    .rs2(T2),
    .out(d0_out)
);

fpadd d1(
    .clk(clk),
    .resetn(resetn),
    .rs1(d0_outn),
    .rs2(T1),
    .out(d1_out)
);

//multiply1
fmul d2(
    .clk(clk),
    .resetn(resetn),
    .rs1(in_reduced),
    .rs2(d1_out),
    .out(d2_out)
);

//adder
fpadd d3(
    .clk(clk),
    .resetn(resetn),
    .rs1(const_two),
    .rs2(d2_outn),
    .out(d3_out)
);

//multiply2
fmul d4(
    .clk(clk),
    .resetn(resetn),
    .rs1(d1_out),
    .rs2(d3_out),
    .out(d4_out)
);

//multiply3
fmul d5(
    .clk(clk),
    .resetn(resetn),
    .rs1(in_reduced),
    .rs2(d4_out),
    .out(d5_out)
);

//adder
fpadd d6(
    .clk(clk),
    .resetn(resetn),
    .rs1(const_two),
    .rs2(d5_outn),
    .out(d6_out)
);

//multiply4
fmul d7(
    .clk(clk),
    .resetn(resetn),
    .rs1(d4_out),
    .rs2(d6_out),
    .out(d7_out)
);

//form output
fmul d8(
    .clk(clk),
    .resetn(resetn),
    .rs1(reciprocal),
    .rs2(rs1),
    .out(out)
);

always@(posedge clk)
    if (!resetn)
        cnt = 0;
    else
        cnt += 1;

// Dump waves
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, fdiv);
end

endmodule