module pipeline(
    input wire [XLEN-1:0] din,
    input wire resetn,
    input wire clk,
    input wire run,
    output wire [XLEN-1:0] dout,
    output reg [XLEN-1:0] realaddr,
    output wire W
);

parameter XLEN = 32;
parameter FLEN = 32;
parameter FIELD_WIDTH = 109;
parameter DEPTH = 16;

parameter ID_WIDTH = $clog2(DEPTH);

//wire trap = 0;
wire [XLEN-1:0] R_in;  // r0, ..., r7 register enables
reg [XLEN-1:0] pc;
reg [XLEN-1:0] PCSrc;
reg [XLEN-1:0] ADDR;
reg pc_incr;
reg ADDR_in;
reg pc_in;
reg enq_ifq, deq_ifq;
reg [2:0] Tstep_D, Tstep_Q;
reg rd_in, frd_in;
wire [4:0] rd;
reg [32:0] G;
wire [4:0] rs1_sel, rs2_sel, rd_sel;
reg [XLEN:0] rs1_i, rs2_i, rd_i;

wire [XLEN-1:0] alu_cdb_data, fpalu_cdb_data, agu_cdb_data;
wire [ID_WIDTH-1:0] alu_cdb_tag, fpalu_cdb_tag, agu_cdb_tag;

reg [XLEN-1:0] cdb_data;
reg [ID_WIDTH-1:0] cdb_tag;
reg cdb_valid;

wire [FIELD_WIDTH-1:0] intalu_data_o, fpalu_data_o, agu_data_o;
wire [31:0] Instruction;
wire [FIELD_WIDTH-1:0] intalu_data_op;
wire alu_data_out_valid, fpalu_data_out_valid, agu_data_out_valid;
wire rd_num;

wire [6:0] alu_opcode;
wire [5:0] alu_funct3;
wire [6:0] alu_funct7;
wire [XLEN-1] alu_BusWires1, alu_BusWires2;
wire [6:0] alu_Imm_funct; 
wire [4:0] alu_reduced_Imm;
wire [31:0] alu_Sum;
wire [ID_WIDTH-1:0] alu_tag;
wire alu_Sum_valid;

//reg wires
wire [XLEN:0] r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11,
  r12, r13, r14, r15, r16, r17, r18, r19, r20, r21, r22, r23, r24, r25, r26, r27, r28
  , r29, r30, r31;
reg [ID_WIDTH-1:0] r_tag;


wire [FLEN-1:0] f0, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11,
f12, f13, f14, f15, f16, f17, f18, f19, f20, f21, f22, f23, f24, f25, f26, f27, f28
, f29, f30, f31;
wire [FLEN-1:0] Fp_in;  // f0, ..., f7 register enables

//state machine governing pc incrementation and branching
parameter fetch = 3'b000,mem_wait = 3'b001, decode = 3'b010;

parameter _R0 = 5'b00000, _R1 = 5'b00001, _R2 = 5'b00010, _R3 = 5'b00011, _R4 = 5'b00100, 
      _R5 = 5'b00101, _R6 = 5'b00110, _R7 = 5'b00111, _R8 = 5'b01000,  _R9 = 5'b01001,  _R10 = 5'b01010,  _R11 = 5'b01011,
        _R12 = 5'b01100,  _R13 = 5'b01101,  _R14 = 5'b01110,  _R15 = 5'b01111,  _R16 = 5'b10000,
        _R17 = 5'b10001,  _R18 = 5'b10010,  _R19 = 5'b10011,  _R20 = 5'b10100,  _R21 = 5'b10101,
          _R22 = 5'b10110,  _R23 = 5'b10111,  _R24 = 5'b11000,  _R25 = 5'b11001,  _R26 = 5'b11010,
          _R27 = 5'b11011,  _R28 = 5'b11100,  _R29 = 5'b11101,  _R30 = 5'b11110,  _R31 = 5'b11111;

//parse out data from dispatcher to alu
assign alu_opcode = intalu_data_o[78:73];
assign alu_funct3 = intalu_data_o[81:79];
assign alu_funct7 = intalu_data_o[104:98];
assign alu_BusWires1 = intalu_data_o[71:40];
assign alu_BusWires2 = intalu_data_o[38:7];
assign alu_Imm_funct = alu_funct7;
assign alu_reduced_Imm = intalu_data_o[97:93];
assign alu_tag = intalu_data_o[108:105];
assign rd_num = intalu_data_o[5:1];

assign rd = rd_num; //TEMPORARY UNTIL FULL REGISTER ACCESS IS DONE
assign rd_in = alu_data_out_valid;

//Bus selections
always@(*) begin
  if (alu_data_out_valid) begin
    cdb_data = alu_Sum;
    cdb_tag = alu_tag;
    cdb_valid = alu_Sum_valid;
  end
  else if (fpalu_data_out_valid) begin
    //cdb_data = fpalu_Sum;
    //cdb_tag = fpaalu_tag;
    //cdb_valid = fpalu_Sum_valid;
  end
  else if (agu_data_out_valid) begin
    //cdb_data = agu_Sum;
    //cdb_tag = agu_tag;
    //cdb_valid = agu_Sum_valid;
  end
  else begin
    //cdb_data = 0;
    //cdb_tag = 0;
    //cdb_valid = 1'b0;
  end
end

// Control FSM flip-flops
// State Register
always @(posedge clk)
  if (!resetn) Tstep_Q <= fetch;
  else Tstep_Q <= Tstep_D;

// Control FSM state table (Next State Logic).
always @(*)
  case (Tstep_Q)
    fetch: begin  // instruction fetch
      if (~run) Tstep_D = fetch;
      else Tstep_D = mem_wait;
    end
    mem_wait: begin  // wait cycle for synchronous memory
      if (!full_ifq) Tstep_D = decode;
      else Tstep_D = mem_wait;
    end
    decode: begin  // enqueue instruction in IFQ
      Tstep_D = mem_wait;
    end
    default: Tstep_D = 3'bxxx;
  endcase

always@(*) begin
    ADDR_in = 1'b0;
    pc_incr = 1'b0;
    enq_ifq = 1'b0;
    deq_ifq = 1'b0;
    pc_in = 1'b0;

    case (Tstep_Q)
    fetch: begin
        //ADDR_in = 1;
        //pc_incr = run;
    end
    mem_wait: begin
        if (!full_ifq) pc_incr = run;
    end
    decode: begin
        ADDR_in = 1;
        enq_ifq = 1;
        if (!empty_ifq) deq_ifq = 1;
    end
    default: ;
    endcase
end

//address for instruction queues
assign realaddr = ADDR;

//pc logic unit 
always@(*)
    PCSrc = pc + 4;

regn reg_ADDR (
    .D(pc), 
    .resetn(resetn),
    .En(ADDR_in),
    .clk(clk),
    .Q(ADDR)
); 

pc_count reg_pc (
    .D(PCSrc),
    .resetn(resetn),
    .clk(clk),
    .En(pc_incr),
    .PLoad(pc_in /*| trap*/),
    .Q(pc)
);

//instantiate dispatcher and send data to it
dispatcher #(XLEN, DEPTH, FIELD_WIDTH) d0(
    .clk(clk),
    .resetn(resetn),
    .enq_ifq(enq_ifq),
    .deq_ifq(deq_ifq),
    .data_in_ifq(din),
    .full_intalu(full_intalu),
    .full_fpalu(full_fpalu),
    .full_agu(full_agu),
    .full_ifq(full_ifq),
    .empty_ifq(empty_ifq),
    .alu_ready_i(1'b1),
    .fpalu_ready_i(fpalu_ready_i), 
    .agu_ready_i(agu_ready_i),
    .rs1_i(rs1_i),
    .rs2_i(rs2_i),
    .rd_i(rd_i),
    .rs1_sel(rs1_sel),
    .rs2_sel(rs2_sel),
    .rd_sel(rd_sel),
    .cdb_tag(cdb_tag),
    .cdb_data(cdb_data),
    .cdb_valid(cdb_valid),
    .alu_data_out_valid(alu_data_out_valid),
    .fpalu_data_out_valid(fpalu_data_out_valid),
    .agu_data_out_valid(agu_data_out_valid),
    .intalu_data_o(intalu_data_o),
    .fpalu_data_o(fpalu_data_o),
    .agu_data_o(agu_data_o)
);

//instantiate functional units and send data to them

alu #(XLEN, ID_WIDTH) alu0(
    .clk(clk),
    .resetn(resetn),
    .data_out_valid(alu_data_out_valid),
    .opcode(alu_opcode),
    .funct3(alu_funct3),
    .funct7(alu_funct7),
    .BusWires1(alu_BusWires1),
    .BusWires2(alu_BusWires2),
    .tag(alu_tag),
    .Imm_funct(alu_Imm_funct),
    .reduced_Imm(alu_reduced_Imm),
    .Sum(alu_Sum),
    .Sum_valid(alu_Sum_valid)
);

//instantiate writeback unit and send data to it


//register files and enables

dec3to8 decX (
    .En(rd_in),
    .W (rd),
    .Y (R_in)
);  // produce r0 - r31 register enables

dec3to8 decY (
    .En(frd_in),
    .W (rd),
    .Y (Fp_in)
);  // produce r0 - r31 register enables

regarray regs (/*AUTOINST*/
    // Outputs
    .r0			(r0[XLEN:0]),
    .r1			(r1[XLEN:0]),
    .r2			(r2[XLEN:0]),
    .r3			(r3[XLEN:0]),
    .r4			(r4[XLEN:0]),
    .r5			(r5[XLEN:0]),
    .r6			(r6[XLEN:0]),
    .r7			(r7[XLEN:0]),
    .r8			(r8[XLEN:0]),
    .r9			(r9[XLEN:0]),
    .r10			(r10[XLEN:0]),
    .r11			(r11[XLEN:0]),
    .r12			(r12[XLEN:0]),
    .r13			(r13[XLEN:0]),
    .r14			(r14[XLEN:0]),
    .r15			(r15[XLEN:0]),
    .r16			(r16[XLEN:0]),
    .r17			(r17[XLEN:0]),
    .r18			(r18[XLEN:0]),
    .r19			(r19[XLEN:0]),
    .r20			(r20[XLEN:0]),
    .r21			(r21[XLEN:0]),
    .r22			(r22[XLEN:0]),
    .r23			(r23[XLEN:0]),
    .r24			(r24[XLEN:0]),
    .r25			(r25[XLEN:0]),
    .r26			(r26[XLEN:0]),
    .r27			(r27[XLEN:0]),
    .r28			(r28[XLEN:0]),
    .r29			(r29[XLEN:0]),
    .r30			(r30[XLEN:0]),
    .r31			(r31[XLEN:0]),
    // Inputs
    .G			({r_tag[ID_WIDTH-1:0], G[32:0]}), // TO FIX INPUT INTO REGARRAY
    .resetn		(resetn),
    .R_in			(R_in[31:0]), 
    .clk			(clk));

/*
regarray fregs (
		 // Outputs
		 .r0			(f0[FLEN-1:0]),
		 .r1			(f1[FLEN-1:0]),
		 .r2			(f2[FLEN-1:0]),
		 .r3			(f3[FLEN-1:0]),
		 .r4			(f4[FLEN-1:0]),
		 .r5			(f5[FLEN-1:0]),
		 .r6			(f6[FLEN-1:0]),
		 .r7			(f7[FLEN-1:0]),
		 .r8			(f8[FLEN-1:0]),
		 .r9			(f9[FLEN-1:0]),
		 .r10			(f10[FLEN-1:0]),
		 .r11			(f11[FLEN-1:0]),
		 .r12			(f12[FLEN-1:0]),
		 .r13			(f13[FLEN-1:0]),
		 .r14			(f14[FLEN-1:0]),
		 .r15			(f15[FLEN-1:0]),
		 .r16			(f16[FLEN-1:0]),
		 .r17			(f17[FLEN-1:0]),
		 .r18			(f18[FLEN-1:0]),
		 .r19			(f19[FLEN-1:0]),
		 .r20			(f20[FLEN-1:0]),
		 .r21			(f21[FLEN-1:0]),
		 .r22			(f22[FLEN-1:0]),
		 .r23			(f23[FLEN-1:0]),
		 .r24			(f24[FLEN-1:0]),
		 .r25			(f25[FLEN-1:0]),
		 .r26			(f26[FLEN-1:0]),
		 .r27			(f27[FLEN-1:0]),
		 .r28			(f28[FLEN-1:0]),
		 .r29			(f29[FLEN-1:0]),
		 .r30			(f30[FLEN-1:0]),
		 .r31			(f31[FLEN-1:0]),
		 // Inputs
		 .G			(G[31:0]),
		 .resetn		(resetn),
		 .R_in			(Fp_in[31:0]), 
		 .clk			(clk));
*/

//Register selection
always@(*) begin
case (rs1_sel)
  _R0: rs1_i = r0;
  _R1: rs1_i = r1;
  _R2: rs1_i = r2;
  _R3: rs1_i = r3;
  _R4: rs1_i = r4;
  _R5: rs1_i = r5;
  _R6: rs1_i = r6;
  _R7: rs1_i = r7;
  _R8: rs1_i = r8;
  _R9: rs1_i = r9;
  _R10: rs1_i = r10;
  _R11: rs1_i = r11;
  _R12: rs1_i = r12;
  _R13: rs1_i = r13;
  _R14: rs1_i = r14;
  _R15: rs1_i = r15;
  _R16: rs1_i = r16;
  _R17: rs1_i = r17;
  _R18: rs1_i = r18;
  _R19: rs1_i = r19;
  _R20: rs1_i = r20;
  _R21: rs1_i = r21;
  _R22: rs1_i = r22;
  _R23: rs1_i = r23;
  _R24: rs1_i = r24;
  _R25: rs1_i = r25;
  _R26: rs1_i = r26;
  _R27: rs1_i = r27;
  _R28: rs1_i = r28;
  _R29: rs1_i = r29;
  _R30: rs1_i = r30;
  _R31: rs1_i = r31;
  default: rs1_i = 33'b0;
endcase
end

//Register selection
always@(*) begin
case (rs2_sel)
  _R0: rs2_i = r0;
  _R1: rs2_i = r1;
  _R2: rs2_i = r2;
  _R3: rs2_i = r3;
  _R4: rs2_i = r4;
  _R5: rs2_i = r5;
  _R6: rs2_i = r6;
  _R7: rs2_i = r7;
  _R8: rs2_i = r8;
  _R9: rs2_i = r9;
  _R10: rs2_i = r10;
  _R11: rs2_i = r11;
  _R12: rs2_i = r12;
  _R13: rs2_i = r13;
  _R14: rs2_i = r14;
  _R15: rs2_i = r15;
  _R16: rs2_i = r16;
  _R17: rs2_i = r17;
  _R18: rs2_i = r18;
  _R19: rs2_i = r19;
  _R20: rs2_i = r20;
  _R21: rs2_i = r21;
  _R22: rs2_i = r22;
  _R23: rs2_i = r23;
  _R24: rs2_i = r24;
  _R25: rs2_i = r25;
  _R26: rs2_i = r26;
  _R27: rs2_i = r27;
  _R28: rs2_i = r28;
  _R29: rs2_i = r29;
  _R30: rs2_i = r30;
  _R31: rs2_i = r31;
  default: rs2_i = 33'b0;
endcase
end

//Register selection
always@(*) begin
case (rd_sel)
  _R0: rd_i = r0;
  _R1: rd_i = r1;
  _R2: rd_i = r2;
  _R3: rd_i = r3;
  _R4: rd_i = r4;
  _R5: rd_i = r5;
  _R6: rd_i = r6;
  _R7: rd_i = r7;
  _R8: rd_i = r8;
  _R9: rd_i = r9;
  _R10: rd_i = r10;
  _R11: rd_i = r11;
  _R12: rd_i = r12;
  _R13: rd_i = r13;
  _R14: rd_i = r14;
  _R15: rd_i = r15;
  _R16: rd_i = r16;
  _R17: rd_i = r17;
  _R18: rd_i = r18;
  _R19: rd_i = r19;
  _R20: rd_i = r20;
  _R21: rd_i = r21;
  _R22: rd_i = r22;
  _R23: rd_i = r23;
  _R24: rd_i = r24;
  _R25: rd_i = r25;
  _R26: rd_i = r26;
  _R27: rd_i = r27;
  _R28: rd_i = r28;
  _R29: rd_i = r29;
  _R30: rd_i = r30;
  _R31: rd_i = r31;
  default: rd_i = 33'b0;
endcase
end

// Dump waves
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, pipeline);
end
endmodule