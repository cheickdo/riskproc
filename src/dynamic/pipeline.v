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

//wire trap = 0;
reg [XLEN-1:0] pc;
reg [XLEN-1:0] PCSrc;
reg [XLEN-1:0] ADDR;
reg pc_incr;
reg ADDR_in;
reg pc_in;
reg enq_ifq, deq_ifq;
reg [2:0] Tstep_D, Tstep_Q;

reg [XLEN-1:0] intalu_data_i, fpalu_data_i, agu_data_i;

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
    .enq_intalu(enq_intalu),
    .enq_fpalu(enq_fpalu),
    .enq_agu(enq_agu),
    .intalu_data_i(intalu_data_i),
    .fpalu_data_i(fpalu_data_i),
    .agu_data_i(agu_data_i)
);

//instantiate issue queues and send data to them
issue_queue intq(
    .clk(clk),
    .resetn(resetn),
    .enq(enq_intalu),
    .deq(1'b0),
    .data_in(intalu_data_i),
    .data_out(),
    .full(),
    .empty()
);
//instantiate functional units and send data to them

//instantiate writeback unit and send data to it

// Dump waves
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, pipeline);
end
endmodule