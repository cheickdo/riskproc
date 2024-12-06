module fpu(
    input clk,
    input resetn,
	input [5:0] operation,
	input [31:0] rs1,
	input [31:0] rs2,
    input [31:0] fcsr,
	output reg [31:0] result
);

parameter FLEN = 32;

reg [FLEN-1:0] G;

wire [FLEN-1:0] fpadd_out, fmul_out, fdiv_out, fpsqrt_out, fcvt_s_w_out, fcvt_s_wu_out, fcvt_w_s_out, fcvt_wu_s_out, fclass_out, fmin_out, fmax_out;
wire [FLEN-1:0] fsgnj_s_out, fsgnjn_s_out, fsgnjx_s_out;

wire NX, UF, OF, DZ, NV;
wire [2:0] rounding;

//CSR assignments
assign NX = fcsr[0];
assign UF = fcsr[1];
assign OF = fcsr[2];
assign DZ = fcsr[3];
assign NV = fcsr[4];

assign rounding = fcsr[7:5];

always@(*)
    case(operation)
        4: result = fcvt_s_w_out;
        5: result = fcvt_s_wu_out;
        6: result = fcvt_w_s_out;
        7: result = fcvt_wu_s_out;
        8: result = fclass_out;
        9: result = fmin_out;
        10: result = fmax_out;
        11: result = fsgnj_s_out;
        12: result = fsgnjn_s_out;
        13: result = fsgnjx_s_out;
        default:;
    endcase

//operation instantiations
fpadd fpu0(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .out(fpadd_out)
);

fmul fpu1(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .out(fmul_out)
);

fdiv fpu2(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .out(fdiv_out)
);

fsqrt fpu3(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .out(fpsqrt_out)
);

fcvt_s_w fpu4(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .out(fcvt_s_w_out)
);

fcvt_s_wu fpu5(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .out(fcvt_s_wu_out)
);

fcvt_w_s fpu6(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .out(fcvt_w_s_out)
);

fcvt_wu_s fpu7(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .out(fcvt_wu_s_out)
);

fclass fpu8(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .out(fclass_out)
);
fmin fpu9(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .out(fmin_out)
);

fmax fpu10(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .out(fmax_out)
);

fsgnj_s fpu11(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .out(fsgnj_s_out)
);

fsgnjn_s fpu12(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .out(fsgnjn_s_out)
);

fsgnjx_s fpu13(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .out(fsgnjx_s_out)
);


// Dump waves
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, fpu);
end

endmodule