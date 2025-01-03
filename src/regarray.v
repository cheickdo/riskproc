module regarray #(parameter XLEN=36) (
  input [XLEN:0] G,
  input resetn,
  input [XLEN-1:0] R_in,
  input clk,
  output  [XLEN:0] r0,
  output  [XLEN:0] r1,
  output  [XLEN:0] r2,
  output  [XLEN:0] r3,
  output  [XLEN:0] r4,
  output  [XLEN:0] r5,
  output  [XLEN:0] r6,
  output  [XLEN:0] r7,
  output  [XLEN:0] r8,
  output  [XLEN:0] r9,
  output  [XLEN:0] r10,
  output  [XLEN:0] r11,
  output  [XLEN:0] r12,
  output  [XLEN:0] r13,
  output  [XLEN:0] r14,
  output  [XLEN:0] r15,
  output  [XLEN:0] r16,
  output  [XLEN:0] r17,
  output  [XLEN:0] r18,
  output  [XLEN:0] r19,
  output  [XLEN:0] r20,
  output  [XLEN:0] r21,
  output  [XLEN:0] r22,
  output  [XLEN:0] r23,
  output  [XLEN:0] r24,
  output  [XLEN:0] r25,
  output  [XLEN:0] r26,
  output  [XLEN:0] r27,
  output  [XLEN:0] r28,
  output  [XLEN:0] r29,
  output  [XLEN:0] r30,
  output  [XLEN:0] r31
);

regn #(37) reg_0 (
  .D(37'b0),
  .resetn(resetn),
  .En(1'b1),
  .clk(clk),
  .Q(r0)
);
regn #(37) reg_1 (
  .D(G),
  .resetn(resetn),
  .En(R_in[1]),
  .clk(clk),
  .Q(r1)
);
regn #(37) reg_2 (
  .D(G),
  .resetn(resetn),
  .En(R_in[2]),
  .clk(clk),
  .Q(r2)
);
regn #(37) reg_3 (
  .D(G),
  .resetn(resetn),
  .En(R_in[3]),
  .clk(clk),
  .Q(r3)
);
regn #(37) reg_4 (
  .D(G),
  .resetn(resetn),
  .En(R_in[4]),
  .clk(clk),
  .Q(r4)
);

regn #(37) reg_5 (
  .D(G),
  .resetn(resetn),
  .En(R_in[5]),
  .clk(clk),
  .Q(r5)
);

regn #(37) reg_6 (
  .D(G),
  .resetn(resetn),
  .En(R_in[6]),
  .clk(clk),
  .Q(r6)
);

regn #(37) reg_7 (
  .D(G),
  .resetn(resetn),
  .En(R_in[7]),
  .clk(clk),
  .Q(r7)
);

regn #(37) reg_8 (
  .D(G),
  .resetn(resetn),
  .En(R_in[8]),
  .clk(clk),
  .Q(r8)
);

regn #(37) reg_9 (
  .D(G),
  .resetn(resetn),
  .En(R_in[9]),
  .clk(clk),
  .Q(r9)
);

regn #(37) reg_10 (
  .D(G),
  .resetn(resetn),
  .En(R_in[10]),
  .clk(clk),
  .Q(r10)
);

regn #(37) reg_11 (
  .D(G),
  .resetn(resetn),
  .En(R_in[11]),
  .clk(clk),
  .Q(r11)
);

regn #(37) reg_12 (
  .D(G),
  .resetn(resetn),
  .En(R_in[12]),
  .clk(clk),
  .Q(r12)
);

regn #(37) reg_13 (
  .D(G),
  .resetn(resetn),
  .En(R_in[13]),
  .clk(clk),
  .Q(r13)
);

regn #(37) reg_14 (
  .D(G),
  .resetn(resetn),
  .En(R_in[14]),
  .clk(clk),
  .Q(r14)
);

regn #(37) reg_15 (
  .D(G),
  .resetn(resetn),
  .En(R_in[15]),
  .clk(clk),
  .Q(r15)
);

regn #(37) reg_16 (
  .D(G),
  .resetn(resetn),
  .En(R_in[16]),
  .clk(clk),
  .Q(r16)
);

regn #(37) reg_17 (
  .D(G),
  .resetn(resetn),
  .En(R_in[17]),
  .clk(clk),
  .Q(r17)
);

regn #(37) reg_18 (
  .D(G),
  .resetn(resetn),
  .En(R_in[18]),
  .clk(clk),
  .Q(r18)
);

regn #(37) reg_19 (
  .D(G),
  .resetn(resetn),
  .En(R_in[19]),
  .clk(clk),
  .Q(r19)
);

regn #(37) reg_20 (
  .D(G),
  .resetn(resetn),
  .En(R_in[20]),
  .clk(clk),
  .Q(r20)
);

regn #(37) reg_21 (
  .D(G),
  .resetn(resetn),
  .En(R_in[21]),
  .clk(clk),
  .Q(r21)
);

regn #(37) reg_22 (
  .D(G),
  .resetn(resetn),
  .En(R_in[22]),
  .clk(clk),
  .Q(r22)
);

regn #(37) reg_23 (
  .D(G),
  .resetn(resetn),
  .En(R_in[23]),
  .clk(clk),
  .Q(r23)
);

regn #(37) reg_24 (
  .D(G),
  .resetn(resetn),
  .En(R_in[24]),
  .clk(clk),
  .Q(r24)
);

regn #(37) reg_25 (
  .D(G),
  .resetn(resetn),
  .En(R_in[25]),
  .clk(clk),
  .Q(r25)
);

regn #(37) reg_26 (
  .D(G),
  .resetn(resetn),
  .En(R_in[26]),
  .clk(clk),
  .Q(r26)
);

regn #(37) reg_27 (
  .D(G),
  .resetn(resetn),
  .En(R_in[27]),
  .clk(clk),
  .Q(r27)
);

regn #(37) reg_28 (
  .D(G),
  .resetn(resetn),
  .En(R_in[28]),
  .clk(clk),
  .Q(r28)
);

regn #(37) reg_29 (
  .D(G),
  .resetn(resetn),
  .En(R_in[29]),
  .clk(clk),
  .Q(r29)
);

regn #(37) reg_30 (
  .D(G),
  .resetn(resetn),
  .En(R_in[30]),
  .clk(clk),
  .Q(r30)
);

regn #(37) reg_31 (
  .D(G),
  .resetn(resetn),
  .En(R_in[31]),
  .clk(clk),
  .Q(r31)
);

endmodule