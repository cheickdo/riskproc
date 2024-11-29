module fregarray(
    input [31:0] G,
    input resetn,
    input [31:0] F_in,
    input clk,
    output  [31:0] f0,
    output  [31:0] f1,
    output  [31:0] f2,
    output  [31:0] f3,
    output  [31:0] f4,
    output  [31:0] f5,
    output  [31:0] f6,
    output  [31:0] f7,
    output  [31:0] f8,
    output  [31:0] f9,
    output  [31:0] f10,
    output  [31:0] f11,
    output  [31:0] f12,
    output  [31:0] f13,
    output  [31:0] f14,
    output  [31:0] f15,
    output  [31:0] f16,
    output  [31:0] f17,
    output  [31:0] f18,
    output  [31:0] f19,
    output  [31:0] f20,
    output  [31:0] f21,
    output  [31:0] f22,
    output  [31:0] f23,
    output  [31:0] f24,
    output  [31:0] f25,
    output  [31:0] f26,
    output  [31:0] f27,
    output  [31:0] f28,
    output  [31:0] f29,
    output  [31:0] f30,
    output  [31:0] f31
);

  regn reg_0 (
      .D(0),
      .resetn(resetn),
      .En(1'b1),
      .clk(clk),
      .Q(f0)
  );
  regn reg_1 (
      .D(G),
      .resetn(resetn),
      .En(F_in[1]),
      .clk(clk),
      .Q(f1)
  );
  regn reg_2 (
      .D(G),
      .resetn(resetn),
      .En(F_in[2]),
      .clk(clk),
      .Q(f2)
  );
  regn reg_3 (
      .D(G),
      .resetn(resetn),
      .En(F_in[3]),
      .clk(clk),
      .Q(f3)
  );
  regn reg_4 (
      .D(G),
      .resetn(resetn),
      .En(F_in[4]),
      .clk(clk),
      .Q(f4)
  );

    regn reg_5 (
      .D(G),
      .resetn(resetn),
      .En(F_in[5]),
      .clk(clk),
      .Q(f5)
  );

    regn reg_6 (
      .D(G),
      .resetn(resetn),
      .En(F_in[6]),
      .clk(clk),
      .Q(f6)
  );

    regn reg_7 (
      .D(G),
      .resetn(resetn),
      .En(F_in[7]),
      .clk(clk),
      .Q(f7)
  );

    regn reg_8 (
      .D(G),
      .resetn(resetn),
      .En(F_in[8]),
      .clk(clk),
      .Q(f8)
  );

    regn reg_9 (
      .D(G),
      .resetn(resetn),
      .En(F_in[9]),
      .clk(clk),
      .Q(f9)
  );

    regn reg_10 (
      .D(G),
      .resetn(resetn),
      .En(F_in[10]),
      .clk(clk),
      .Q(f10)
  );

    regn reg_11 (
      .D(G),
      .resetn(resetn),
      .En(F_in[11]),
      .clk(clk),
      .Q(f11)
  );

    regn reg_12 (
      .D(G),
      .resetn(resetn),
      .En(F_in[12]),
      .clk(clk),
      .Q(f12)
  );

    regn reg_13 (
      .D(G),
      .resetn(resetn),
      .En(F_in[13]),
      .clk(clk),
      .Q(f13)
  );

    regn reg_14 (
      .D(G),
      .resetn(resetn),
      .En(F_in[14]),
      .clk(clk),
      .Q(f14)
  );

    regn reg_15 (
      .D(G),
      .resetn(resetn),
      .En(F_in[15]),
      .clk(clk),
      .Q(f15)
  );

    regn reg_16 (
      .D(G),
      .resetn(resetn),
      .En(F_in[16]),
      .clk(clk),
      .Q(f16)
  );

    regn reg_17 (
      .D(G),
      .resetn(resetn),
      .En(F_in[17]),
      .clk(clk),
      .Q(f17)
  );

    regn reg_18 (
      .D(G),
      .resetn(resetn),
      .En(F_in[18]),
      .clk(clk),
      .Q(f18)
  );

    regn reg_19 (
      .D(G),
      .resetn(resetn),
      .En(F_in[19]),
      .clk(clk),
      .Q(f19)
  );

    regn reg_20 (
      .D(G),
      .resetn(resetn),
      .En(F_in[20]),
      .clk(clk),
      .Q(f20)
  );

    regn reg_21 (
      .D(G),
      .resetn(resetn),
      .En(F_in[21]),
      .clk(clk),
      .Q(f21)
  );

    regn reg_22 (
      .D(G),
      .resetn(resetn),
      .En(F_in[22]),
      .clk(clk),
      .Q(f22)
  );

    regn reg_23 (
      .D(G),
      .resetn(resetn),
      .En(F_in[23]),
      .clk(clk),
      .Q(f23)
  );

    regn reg_24 (
      .D(G),
      .resetn(resetn),
      .En(F_in[24]),
      .clk(clk),
      .Q(f24)
  );

    regn reg_25 (
      .D(G),
      .resetn(resetn),
      .En(F_in[25]),
      .clk(clk),
      .Q(f25)
  );

    regn reg_26 (
      .D(G),
      .resetn(resetn),
      .En(F_in[26]),
      .clk(clk),
      .Q(f26)
  );

    regn reg_27 (
      .D(G),
      .resetn(resetn),
      .En(F_in[27]),
      .clk(clk),
      .Q(f27)
  );

    regn reg_28 (
      .D(G),
      .resetn(resetn),
      .En(F_in[28]),
      .clk(clk),
      .Q(f28)
  );

    regn reg_29 (
      .D(G),
      .resetn(resetn),
      .En(F_in[29]),
      .clk(clk),
      .Q(f29)
  );

    regn reg_30 (
      .D(G),
      .resetn(resetn),
      .En(F_in[30]),
      .clk(clk),
      .Q(f30)
  );

    regn reg_31 (
      .D(G),
      .resetn(resetn),
      .En(F_in[31]),
      .clk(clk),
      .Q(f31)
  );

endmodule