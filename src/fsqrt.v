/*
Single Precision IEEE 754 floating point square root function through Newton-Raphson iteration(fast square root algorithm)
    chk
*/
module fsqrt(
    input clk,
    input resetn,
    input [31:0] rs1,
    input [31:0] rs2,
    output [31:0] out
);

wire [31:0] inv_sqrt;

reg [31:0] cnt;

wire s1;
wire [7:0] e1;
wire [22:0] m1;
wire [31:0] magic;
wire [31:0] rs1xh, rs1xhn, const_half, const_1_and_half, scaled_rs1, scaled_rs1n, i, i_sqr, scaled_i_sqr,y,y_sqr, scaled_y_sqr, rhs1, rhs2;

wire [31:0] const_two, const_init;

assign s1 = rs1[31];
assign e1 = rs1[30:23];
assign m1 = rs1[22:0];

assign const_half = 32'h3f000000; //0.5
assign const_1_and_half =   32'h3fc00000; //1.5
assign magic = 32'h5F3759DF;
assign scaled_rs1 = rs1 >> 1;
assign scaled_rs1n = {~scaled_rs1[31], scaled_rs1[30:0]}; //integer subtraction?
assign rs1xhn = {~rs1xh[31], rs1xh[30:0]};

//halve input (asynchronous to first couple stages)
fmul sq0(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(const_half),
    .out(rs1xh)
);

//compute first order approximation
//fpadd sq1(
//    .clk(clk),
//    .resetn(resetn),
//    .rs1(magic),
//    .rs2(scaled_rs1n),
//    .out(i)
//);
assign i = magic - scaled_rs1;


//compute newton raphson iter1
//multiply1
fmul sq2(
    .clk(clk),
    .resetn(resetn),
    .rs1(i),
    .rs2(i),
    .out(i_sqr)
);

//multiply2
fmul sq3(
    .clk(clk),
    .resetn(resetn),
    .rs1(i_sqr),
    .rs2(rs1xhn),
    .out(scaled_i_sqr)
);

//add
fpadd sq4(
    .clk(clk),
    .resetn(resetn),
    .rs1(scaled_i_sqr),
    .rs2(const_1_and_half),
    .out(rhs1)
);    

fmul sq5(
    .clk(clk),
    .resetn(resetn),
    .rs1(rhs1),
    .rs2(i),
    .out(y)
);

//compute newton raphson iter1
//multiply1
fmul sq6(
    .clk(clk),
    .resetn(resetn),
    .rs1(y),
    .rs2(y),
    .out(y_sqr)
);

//multiply2
fmul sq7(
    .clk(clk),
    .resetn(resetn),
    .rs1(y_sqr),
    .rs2(rs1xhn),
    .out(scaled_y_sqr)
);

//add
fpadd sq8(
    .clk(clk),
    .resetn(resetn),
    .rs1(scaled_y_sqr),
    .rs2(const_1_and_half),
    .out(rhs2)
);

//multiply3
fmul sq9(
    .clk(clk),
    .resetn(resetn),
    .rs1(rhs2),
    .rs2(y),
    .out(inv_sqrt)
);

//compute sqrt
fmul sq10(
    .clk(clk),
    .resetn(resetn),
    .rs1(inv_sqrt),
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
    $dumpvars(1, fsqrt);
end

endmodule