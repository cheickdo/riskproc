module proc (
    input wire [31:0] din,
    input wire resetn,
    input wire clk,
    input wire run,
    output wire [31:0] dout,
    output reg [31:0] realaddr,
    output wire W
);

  wire [0:31] R_in;  // r0, ..., r7 register enables
  reg rs1_in, rs2_in, rd_in, IR_in, ADDR_in, Done, dout_in, load, din_in, G_in, F_in, AddSub, Arith;
  reg [2:0] Tstep_Q, Tstep_D;
  reg [31:0] BusWires1, BusWires2, PCSrc;
  reg [5:0] Select1, Select2;  // BusWires selector
  reg [31:0] Sum;
  reg ALU_Cout;  // ALU carry-out
  wire [2:0] funct3;
  wire [7:0] opcode, funct7;
  wire [4:0] rs1, rd, rs2;  // instruction opcode and register operands
  reg [11:0] I_Imm;
  wire [31:0] r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11,
    r12, r13, r14, r15, r16, r17, r18, r19, r20, r21, r22, r23, r24, r25, r26, r27, r28
    , r29, r30, r31, pc, A;
  wire [31:0] G;
  wire [31:0] IR;
  reg pc_incr;  // used to increment the pc
  reg sp_incr, sp_decr;
  reg pc_in; 
  reg  W_D;  // used for write signal
  reg Imm;
  wire C, N, Z;
  wire [31:0] ADDR;

  assign opcode = IR[6:0];
  assign rd = IR[11:7];
  assign funct3 = IR[14:12];
  assign rs1  = IR[19:15];
  assign rs2 = IR[24:20];
  assign funct7 = IR[31:25];
  assign I_Imm = IR[31:20];

  dec3to8 decX (
      .En(rd_in),
      .W (rd),
      .Y (R_in)
  );  // produce r0 - r7 register enables

  parameter fetch = 3'b000,mem_wait = 3'b001, decode = 3'b010,  exec = 3'b011, access = 3'b100, write_back = 3'b101;

  // Control FSM state table (Next State Logic).
  // Is a function of current state (Tstep_Q) and inputs (run and Done)
  always @(*)
    case (Tstep_Q)
      fetch: begin  // instruction fetch
        if (~run) Tstep_D = fetch;
        else Tstep_D = mem_wait;
      end
      mem_wait: begin  // wait cycle for synchronous memory
        Tstep_D = decode;
      end
      decode: begin  // this time step stores the instruction word in IR
        Tstep_D =  exec;
      end
      exec: begin
        if (Done) Tstep_D = fetch;
        else Tstep_D = access;
      end
      access: begin
        if (Done) Tstep_D = fetch;
        else Tstep_D = write_back;
      end
      write_back: begin  // instructions end after this time step
        Tstep_D = fetch;
      end
      default: Tstep_D = 3'bxxx;
    endcase


  parameter R_type = 7'b0110011, I_type_1=7'b0000011, I_type_2 = 7'b0010011;
  parameter SB_type = 7'b1100111, S_type = 7'b0100011, U_type = 7'b0110111, UJ_type=7'b1101111;

  //arithmetic instruction funct3
  parameter SLL = 3'b001, XOR = 3'b100, SRL = 3'b101, SRA = 3'b101, OR = 3'b110, AND = 3'b111;

  // selectors for the BusWires multiplexer
  parameter _r0 = 5'b00000, _R1 = 5'b00001, _R2 = 5'b00010, _R3 = 5'b00011, _R4 = 5'b00100, 
        _R5 = 5'b00101, _R6 = 5'b00110, _R7 = 5'b00111, _R8 = 5'b01000,  _R9 = 5'b01001,  _R10 = 5'b01010,  _R11 = 5'b01011,
         _R12 = 5'b01100,  _R13 = 5'b01101,  _R14 = 5'b01110,  _R15 = 5'b01111,  _R16 = 5'b10000,
          _R17 = 5'b10001,  _R18 = 5'b10010,  _R19 = 5'b10011,  _R20 = 5'b10100,  _R21 = 5'b10101,
           _R22 = 5'b10110,  _R23 = 5'b10111,  _R24 = 5'b11000,  _R25 = 5'b11001,  _R26 = 5'b11010,
            _R27 = 5'b11011,  _R28 = 5'b11100,  _R29 = 5'b11101,  _R30 = 5'b11110,  _R31 = 5'b11111;

  // Control FSM outputs
  always @(*) begin  // Output Logic

    // default values for control signals
    rs1_in     = 1'b0;
    rd_in = 1'b0;
    //A_in      = 1'b0;
    G_in      = 1'b0;
    F_in      = 1'b0;
    IR_in     = 1'b0;
    dout_in   = 1'b0;
    ADDR_in   = 1'b0;
    Select1    = 5'bxxxxx;
    Select2 = 5'bxxxxx;
    Arith = 1'b0;
    AddSub    = 1'b0;
    Imm = 1'b0;
    din_in = 1'b0;
    W_D       = 1'b0;
    Done      = 1'b0;
    pc_in     = 1'b0;  // default pc enable
    pc_incr   = 1'b0;
    sp_incr   = 1'b0;
    sp_decr   = 1'b0;
    load = 1'b0;

    case (Tstep_Q)

      fetch: begin  // fetch the instruction
        ADDR_in = 1'b1;
        pc_incr = run;  // to increment pc
      end

      mem_wait: begin  // wait cycle for synchronous memory
      end

      decode: IR_in = 1'b1;  // store instruction on din in IR

      exec:  // execute instruction
      case (opcode)
        R_type: begin
          Select1 = rs1;
          Select2 = rs2;
          G_in = 1'b1;

          case (funct3)
            0: begin //add 
              if (funct7[5] == 1) AddSub = 1'b1;
            end
            default: begin
              Arith = 1'b1;
            end

          endcase
        end

        I_type_1: begin
          case(funct3)
            1: begin //load halfword
              Imm = 1'b1;
              Select1 = rs1;
              G_in = 1'b1;
              din_in = 1'b1; //new change
            end
            default: ;
          endcase
        end
        
        I_type_2: begin
          Select1 = rs1;
          Imm = 1'b1;
          G_in = 1'b1;
          case (funct3)
            0: begin //add is default
            end
            default: begin
              Arith = 1'b1;
            end

          endcase
        end
        default: ;
      endcase

      access:  // define signals access
      case (opcode)
        R_type: begin
          case (funct3)
            0: begin //add
            end

          endcase
        end

        I_type_1: begin
          case(funct3) 
            1: begin // load halfword
              //ADDR_in = 1'b1;
              load = 1'b1;
            end
          endcase
        end
          
        I_type_2: begin
          case (funct3)
            0: begin
            end

          endcase
        end
        default: ;
      endcase

      write_back:  // define write_back
      case (opcode)
      R_type: begin
        case (funct3)
          0: begin
            rd_in = 1'b1;
            Done = 1'b1;
          end
        endcase
      end

      I_type_1: begin
        case (funct3)
          1: begin //load halfword
            rd_in = 1'b1;
            Done = 1'b1;
            //din_in = 1'b1;
          end

        endcase
      end

      I_type_2: begin
          case (funct3)
            0: begin
              rd_in = 1'b1;
              Done = 1'b1;
            end

          endcase
        end
        default: ;
      endcase

      default: ;
    endcase
  end

  // Control FSM flip-flops
  // State Register
  always @(posedge clk)
    if (!resetn) Tstep_Q <= fetch;
    else Tstep_Q <= Tstep_D;

  regn reg_0 (
      .D(G),
      .resetn(resetn),
      .En(R_in[0]),
      .clk(clk),
      .Q(r0)
  );
  regn reg_1 (
      .D(G),
      .resetn(resetn),
      .En(R_in[1]),
      .clk(clk),
      .Q(r1)
  );
  regn reg_2 (
      .D(G),
      .resetn(resetn),
      .En(R_in[2]),
      .clk(clk),
      .Q(r2)
  );
  regn reg_3 (
      .D(G),
      .resetn(resetn),
      .En(R_in[3]),
      .clk(clk),
      .Q(r3)
  );
  regn reg_4 (
      .D(G),
      .resetn(resetn),
      .En(R_in[4]),
      .clk(clk),
      .Q(r4)
  );

    regn reg_5 (
      .D(G),
      .resetn(resetn),
      .En(R_in[5]),
      .clk(clk),
      .Q(r4)
  );

    regn reg_6 (
      .D(G),
      .resetn(resetn),
      .En(R_in[6]),
      .clk(clk),
      .Q(r4)
  );

    regn reg_7 (
      .D(G),
      .resetn(resetn),
      .En(R_in[7]),
      .clk(clk),
      .Q(r4)
  );

    regn reg_8 (
      .D(G),
      .resetn(resetn),
      .En(R_in[8]),
      .clk(clk),
      .Q(r4)
  );

    regn reg_9 (
      .D(G),
      .resetn(resetn),
      .En(R_in[9]),
      .clk(clk),
      .Q(r4)
  );

    regn reg_10 (
      .D(G),
      .resetn(resetn),
      .En(R_in[10]),
      .clk(clk),
      .Q(r4)
  );

    regn reg_11 (
      .D(G),
      .resetn(resetn),
      .En(R_in[11]),
      .clk(clk),
      .Q(r4)
  );

    regn reg_12 (
      .D(G),
      .resetn(resetn),
      .En(R_in[12]),
      .clk(clk),
      .Q(r4)
  );

    regn reg_13 (
      .D(G),
      .resetn(resetn),
      .En(R_in[13]),
      .clk(clk),
      .Q(r4)
  );

    regn reg_14 (
      .D(G),
      .resetn(resetn),
      .En(R_in[14]),
      .clk(clk),
      .Q(r4)
  );

    regn reg_15 (
      .D(G),
      .resetn(resetn),
      .En(R_in[15]),
      .clk(clk),
      .Q(r4)
  );

    regn reg_16 (
      .D(G),
      .resetn(resetn),
      .En(R_in[16]),
      .clk(clk),
      .Q(r4)
  );

    regn reg_17 (
      .D(G),
      .resetn(resetn),
      .En(R_in[17]),
      .clk(clk),
      .Q(r4)
  );

    regn reg_18 (
      .D(G),
      .resetn(resetn),
      .En(R_in[18]),
      .clk(clk),
      .Q(r4)
  );

    regn reg_19 (
      .D(G),
      .resetn(resetn),
      .En(R_in[19]),
      .clk(clk),
      .Q(r4)
  );

    regn reg_20 (
      .D(G),
      .resetn(resetn),
      .En(R_in[20]),
      .clk(clk),
      .Q(r4)
  );

    regn reg_21 (
      .D(G),
      .resetn(resetn),
      .En(R_in[21]),
      .clk(clk),
      .Q(r4)
  );

    regn reg_22 (
      .D(G),
      .resetn(resetn),
      .En(R_in[22]),
      .clk(clk),
      .Q(r4)
  );

    regn reg_23 (
      .D(G),
      .resetn(resetn),
      .En(R_in[23]),
      .clk(clk),
      .Q(r4)
  );

    regn reg_24 (
      .D(G),
      .resetn(resetn),
      .En(R_in[24]),
      .clk(clk),
      .Q(r4)
  );

    regn reg_25 (
      .D(G),
      .resetn(resetn),
      .En(R_in[25]),
      .clk(clk),
      .Q(r4)
  );

    regn reg_26 (
      .D(G),
      .resetn(resetn),
      .En(R_in[26]),
      .clk(clk),
      .Q(r4)
  );

    regn reg_27 (
      .D(G),
      .resetn(resetn),
      .En(R_in[27]),
      .clk(clk),
      .Q(r4)
  );

    regn reg_28 (
      .D(G),
      .resetn(resetn),
      .En(R_in[28]),
      .clk(clk),
      .Q(r4)
  );

    regn reg_29 (
      .D(G),
      .resetn(resetn),
      .En(R_in[29]),
      .clk(clk),
      .Q(r4)
  );

    regn reg_30 (
      .D(G),
      .resetn(resetn),
      .En(R_in[30]),
      .clk(clk),
      .Q(r4)
  );

    regn reg_31 (
      .D(G),
      .resetn(resetn),
      .En(R_in[31]),
      .clk(clk),
      .Q(r4)
  );

  // program counter
  pc_count reg_pc (
      .D(PCSrc),
      .resetn(resetn),
      .clk(clk),
      .En(pc_incr),
      .PLoad(pc_in),
      .Q(pc)
  );

  regn reg_dout (
      .D(G),
      .resetn(resetn),
      .En(dout_in),
      .clk(clk),
      .Q(dout)
  );

  regn reg_ADDR (
      .D(pc), //changed G to pc since G is used in realaddr
      .resetn(resetn),
      .En(ADDR_in),
      .clk(clk),
      .Q(ADDR)
  ); //check load, if yes, ADDR <-

  always@(*)
    if (load) realaddr = G;
    else realaddr = ADDR;

  regn reg_IR (
      .D(din),
      .resetn(resetn),
      .En(IR_in),
      .clk(clk),
      .Q(IR)
  );

  regn #(.n(1)) reg_W (
      .D(W_D),
      .resetn(resetn),
      .En(1'b1),
      .clk(clk),
      .Q(W)
  );

  parameter lsl = 2'b00, lsr = 2'b01, asr = 2'b10, ror = 2'b11;
  wire [1:0] shift_type;
  assign shift_type = IR[6:5];

  //pc logic unit, add branch functionality by having ALU operations and a mux
  always @(*)
    PCSrc = pc + 4;


  // alu
  always @(*)
    if (din_in) Sum = din;
    else if (Arith) //set of R-type non-add arithmetic instructions
      case (funct3)
        SLL: {ALU_Cout, Sum} = BusWires1 << BusWires2;
        SRL: {ALU_Cout, Sum} = BusWires1 >> BusWires2;
        //SRA: {ALU_Cout, Sum} = {{32{BusWires1[15]}}, BusWires1} >> BusWires2;
        XOR: {ALU_Cout, Sum} = BusWires1 ^ BusWires2;
        OR: {ALU_Cout, Sum} = BusWires1 | BusWires2;
        AND: {ALU_Cout, Sum} = BusWires1 & BusWires2;
      endcase
    else if (AddSub) {ALU_Cout, Sum} = BusWires1 + ~BusWires2 + 32'b1; //sub
    else {ALU_Cout, Sum} = BusWires1 + BusWires2; //add

  regn reg_G (
      .D(Sum),
      .resetn(resetn),
      .En(G_in),
      .clk(clk),
      .Q(G)
  );

  // define the internal processor bus
  always @(*)
    case (Select1)
      _r0: BusWires1 = r0;
      _R1: BusWires1 = r1;
      _R2: BusWires1 = r2;
      _R3: BusWires1 = r3;
      _R4: BusWires1 = r4;
      _R5: BusWires1 = r5;
      _R6: BusWires1 = r6;
      _R7: BusWires1 = r7;
      _R8: BusWires1 = r8;
      _R9: BusWires1 = r9;
      _R10: BusWires1 = r10;
      _R11: BusWires1 = r11;
      _R12: BusWires1 = r12;
      _R13: BusWires1 = r13;
      _R14: BusWires1 = r14;
      _R15: BusWires1 = r15;
      _R16: BusWires1 = r16;
      _R17: BusWires1 = r17;
      _R18: BusWires1 = r18;
      _R19: BusWires1 = r19;
      _R20: BusWires1 = r20;
      _R21: BusWires1 = r21;
      _R22: BusWires1 = r22;
      _R23: BusWires1 = r23;
      _R24: BusWires1 = r24;
      _R25: BusWires1 = r25;
      _R26: BusWires1 = r26;
      _R27: BusWires1 = r27;
      _R28: BusWires1 = r28;
      _R29: BusWires1 = r29;
      _R30: BusWires1 = r30;
      _R31: BusWires1 = r31;
      default: BusWires1 = 32'bx;
    endcase

    always @(*)
    if (Imm) begin
      BusWires2 = {21'b0,I_Imm};
    end
    else begin
      case (Select2)
        _r0: BusWires2 = r0;
        _R1: BusWires2 = r1;
        _R2: BusWires2 = r2;
        _R3: BusWires2 = r3;
        _R4: BusWires2 = r4;
        _R5: BusWires2 = r5;
        _R6: BusWires2 = r6;
        _R7: BusWires2 = r7;
        _R8: BusWires2 = r8;
        _R9: BusWires2 = r9;
        _R10: BusWires2 = r10;
        _R11: BusWires2 = r11;
        _R12: BusWires2 = r12;
        _R13: BusWires2 = r13;
        _R14: BusWires2 = r14;
        _R15: BusWires2 = r15;
        _R16: BusWires2 = r16;
        _R17: BusWires2 = r17;
        _R18: BusWires2 = r18;
        _R19: BusWires2 = r19;
        _R20: BusWires2 = r20;
        _R21: BusWires2 = r21;
        _R22: BusWires2 = r22;
        _R23: BusWires2 = r23;
        _R24: BusWires2 = r24;
        _R25: BusWires2 = r25;
        _R26: BusWires2 = r26;
        _R27: BusWires2 = r27;
        _R28: BusWires2 = r28;
        _R29: BusWires2 = r29;
        _R30: BusWires2 = r30;
        _R31: BusWires2 = r31;
        default: BusWires2 = 32'bx;
      endcase
    end

  regn #(
      .n(3)
  ) reg_F (
      .D({ALU_Cout, Sum[31], (Sum == 0)}),
      .resetn(resetn),
      .clk(clk),
      .En(F_in),
      .Q({C, N, Z})
  );

  // Dump waves
  initial begin
      $dumpfile("dump.vcd");
      $dumpvars(1, proc);
  end
endmodule

module pc_count (
    input wire [31:0] D,
    input wire resetn,
    input wire clk,
    input wire En,
    input wire PLoad,
    output reg [31:0] Q
);
  always @(posedge clk)
    if (!resetn) Q <= 16'b0;
    else if (PLoad) Q <= D;
    else if (En) Q <= Q + 1'b1;
endmodule

module sp_count (  // sync. up/down counter w/ parallel load & active-low reset
    input wire [31:0] D,
    input wire resetn,
    input wire clk,
    input wire Up,
    input wire Down,
    input wire PLoad,
    output reg [31:0] Q
);
  always @(posedge clk)
    if (!resetn) Q <= 32'b0;
    else if (PLoad) Q <= D;
    else if (Up) Q <= Q + 1'b1;
    else if (Down) Q <= Q - 1'b1;
endmodule

module dec3to8 (
    input wire En,  // enable
    input wire [4:0] W,
    output reg [0:31] Y
);
  always @(*)
    if (!En) Y = 11'b00000000;
    else
      case (W) 
        5'b00000: Y = 32'b10000000000000000000000000000000;
        5'b00001: Y = 32'b01000000000000000000000000000000;
        5'b00010: Y = 32'b00100000000000000000000000000000;
        5'b00011: Y = 32'b00010000000000000000000000000000;
        5'b00100: Y = 32'b00001000000000000000000000000000;
        5'b00101: Y = 32'b00000100000000000000000000000000;
        5'b00110: Y = 32'b00000010000000000000000000000000;
        5'b00111: Y = 32'b00000001000000000000000000000000;
        5'b01000: Y = 32'b00000000100000000000000000000000;
        5'b01001: Y = 32'b00000000010000000000000000000000;
        5'b01010: Y = 32'b00000000001000000000000000000000;
        5'b01011: Y = 32'b00000000000100000000000000000000;
        5'b01100: Y = 32'b00000000000010000000000000000000;
        5'b01101: Y = 32'b00000000000001000000000000000000;
        5'b01110: Y = 32'b00000000000000100000000000000000;
        5'b01111: Y = 32'b00000000000000010000000000000000;
        5'b10000: Y = 32'b00000000000000001000000000000000;
        5'b10001: Y = 32'b00000000000000000100000000000000;
        5'b10010: Y = 32'b00000000000000000010000000000000;
        5'b10011: Y = 32'b00000000000000000001000000000000;
        5'b10100: Y = 32'b00000000000000000000100000000000;
        5'b10101: Y = 32'b00000000000000000000010000000000;
        5'b10110: Y = 32'b00000000000000000000001000000000;
        5'b10111: Y = 32'b00000000000000000000000100000000;
        5'b11000: Y = 32'b00000000000000000000000010000000;
        5'b11001: Y = 32'b00000000000000000000000001000000;
        5'b11010: Y = 32'b00000000000000000000000000100000;
        5'b11011: Y = 32'b00000000000000000000000000010000;
        5'b11100: Y = 32'b00000000000000000000000000001000;
        5'b11101: Y = 32'b00000000000000000000000000000100;
        5'b11110: Y = 32'b00000000000000000000000000000010;
        5'b11111: Y = 32'b00000000000000000000000000000001;
        default: Y = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
      endcase
endmodule