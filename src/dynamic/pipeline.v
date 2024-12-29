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
parameter FIELD_WIDTH = 55;

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
reg [31:0] G;

wire [FIELD_WIDTH-1:0] intalu_data_o, fpalu_data_o, agu_data_o;

//reg wires
wire [XLEN-1:0] r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11,
  r12, r13, r14, r15, r16, r17, r18, r19, r20, r21, r22, r23, r24, r25, r26, r27, r28
  , r29, r30, r31;

wire [FLEN-1:0] f0, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11,
f12, f13, f14, f15, f16, f17, f18, f19, f20, f21, f22, f23, f24, f25, f26, f27, f28
, f29, f30, f31;
wire [FLEN-1:0] Fp_in;  // f0, ..., f7 register enables

//state machine governing pc incrementation and branching
parameter fetch = 3'b000,mem_wait = 3'b001, decode = 3'b010;

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
dispatcher d0(
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
    .intalu_data_o(intalu_data_o),
    .fpalu_data_o(fpalu_data_o),
    .agu_data_o(agu_data_o)
);

//instantiate functional units and send data to them

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
    .r0			(r0[XLEN-1:0]),
    .r1			(r1[XLEN-1:0]),
    .r2			(r2[XLEN-1:0]),
    .r3			(r3[XLEN-1:0]),
    .r4			(r4[XLEN-1:0]),
    .r5			(r5[XLEN-1:0]),
    .r6			(r6[XLEN-1:0]),
    .r7			(r7[XLEN-1:0]),
    .r8			(r8[XLEN-1:0]),
    .r9			(r9[XLEN-1:0]),
    .r10			(r10[XLEN-1:0]),
    .r11			(r11[XLEN-1:0]),
    .r12			(r12[XLEN-1:0]),
    .r13			(r13[XLEN-1:0]),
    .r14			(r14[XLEN-1:0]),
    .r15			(r15[XLEN-1:0]),
    .r16			(r16[XLEN-1:0]),
    .r17			(r17[XLEN-1:0]),
    .r18			(r18[XLEN-1:0]),
    .r19			(r19[XLEN-1:0]),
    .r20			(r20[XLEN-1:0]),
    .r21			(r21[XLEN-1:0]),
    .r22			(r22[XLEN-1:0]),
    .r23			(r23[XLEN-1:0]),
    .r24			(r24[XLEN-1:0]),
    .r25			(r25[XLEN-1:0]),
    .r26			(r26[XLEN-1:0]),
    .r27			(r27[XLEN-1:0]),
    .r28			(r28[XLEN-1:0]),
    .r29			(r29[XLEN-1:0]),
    .r30			(r30[XLEN-1:0]),
    .r31			(r31[XLEN-1:0]),
    // Inputs
    .G			(G[31:0]),
    .resetn		(resetn),
    .R_in			(R_in[31:0]), 
    .clk			(clk));

regarray fregs (/*AUTOINST*/
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

// Dump waves
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, pipeline);
end
endmodule