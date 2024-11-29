module fpu(
    input clk,
    input resetn
);
    parameter FLEN = 32;

    reg [FLEN-1:0] G;
    reg [FLEN-1:0] fcsr;

    wire [FLEN-1:0] f0, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11,
        f12, f13, f14, f15, f16, f17, f18, f19, f20, f21, f22, f23, f24, f25, f26, f27, f28
        , f29, f30, f31;
    wire [FLEN-1:0] F_in;  // f0, ..., f7 register enables


regarray regs (/*AUTOINST*/
		 // Outputs
		 .f0			(f0[FLEN-1:0]),
		 .f1			(f1[FLEN-1:0]),
		 .f2			(f2[FLEN-1:0]),
		 .f3			(f3[FLEN-1:0]),
		 .f4			(f4[FLEN-1:0]),
		 .f5			(f5[FLEN-1:0]),
		 .f6			(f6[FLEN-1:0]),
		 .f7			(f7[FLEN-1:0]),
		 .f8			(f8[FLEN-1:0]),
		 .f9			(f9[FLEN-1:0]),
		 .f10			(f10[FLEN-1:0]),
		 .f11			(f11[FLEN-1:0]),
		 .f12			(f12[FLEN-1:0]),
		 .f13			(f13[FLEN-1:0]),
		 .f14			(f14[FLEN-1:0]),
		 .f15			(f15[FLEN-1:0]),
		 .f16			(f16[FLEN-1:0]),
		 .f17			(f17[FLEN-1:0]),
		 .f18			(f18[FLEN-1:0]),
		 .f19			(f19[FLEN-1:0]),
		 .f20			(f20[FLEN-1:0]),
		 .f21			(f21[FLEN-1:0]),
		 .f22			(f22[FLEN-1:0]),
		 .f23			(f23[FLEN-1:0]),
		 .f24			(f24[FLEN-1:0]),
		 .f25			(f25[FLEN-1:0]),
		 .f26			(f26[FLEN-1:0]),
		 .f27			(f27[FLEN-1:0]),
		 .f28			(f28[FLEN-1:0]),
		 .f29			(f29[FLEN-1:0]),
		 .f30			(f30[FLEN-1:0]),
		 .f31			(f31[FLEN-1:0]),
		 // Inputs
		 .G			(G[31:0]),
		 .resetn		(resetn),
		 .F_in			(F_in[31:0]), //must be in order?? 
		 .clk			(clk));


endmodule