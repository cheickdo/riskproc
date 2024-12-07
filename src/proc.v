module proc (
  input wire [31:0] din,
  input wire resetn,
  input wire clk,
  input wire run,
  output wire [XLEN-1:0] dout,
  output reg [XLEN-1:0] realaddr,
  output wire W
);

parameter XLEN = 32;
parameter FLEN = 32;

wire [XLEN-1:0] R_in;  // r0, ..., r7 register enables
reg rs1_in, rs2_in, rd_in, frd_in, IR_in, ADDR_in, Done, dout_in, 
  load, din_in, G_in,F_in, AddSub, Arith, zero_extend, branch,
    mul_arith, ret, sys_clear, multicycle, count_rst, count_en;
reg [1:0] width;
reg [2:0] Tstep_Q, Tstep_D;
reg signed [XLEN-1:0] BusWires1;
reg [XLEN-1:0] BusWires2,BusWires3, PCSrc;
reg [5:0] Select1, Select2, Select3;  // BusWires selector
reg fpSel, fBusSel;
reg [31:0] fstage;

reg [XLEN-1:0] Sum_full;
reg [XLEN-1:0] fSum;
wire [7:0] Sum_byte = Sum_full[7:0];
wire [15:0] Sum_half = Sum_full[15:0];
reg [XLEN-1:0] Sum;
wire [64:0] sproduct;
wire [64:0] product;
wire [64:0] suproduct;

reg ALU_Cout;  // ALU carry-out
wire [2:0] funct3;
wire [6:0] opcode, funct7;
wire [4:0] rs1, rs3, rd, rs2;  // instruction opcode and register operands
wire [11:0] I_Imm, S_Imm, B_Imm;
//wire [9:0] J_Imm; //Not sure if this width is correct
wire [20:0] UJ_Imm;
wire [19:0] U_Imm; 

//reg wires
wire [XLEN-1:0] r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11,
  r12, r13, r14, r15, r16, r17, r18, r19, r20, r21, r22, r23, r24, r25, r26, r27, r28
  , r29, r30, r31, pc, A;

wire [FLEN-1:0] f0, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11,
f12, f13, f14, f15, f16, f17, f18, f19, f20, f21, f22, f23, f24, f25, f26, f27, f28
, f29, f30, f31;
wire [FLEN-1:0] Fp_in;  // f0, ..., f7 register enables
reg [5:0] fop;

wire [XLEN-1:0] G;
wire [XLEN-1:0] IR;
reg pc_incr;  // used to increment the pc
reg sp_incr, sp_decr;
reg pc_in; 
reg  W_D;  // used for write signal
reg Imm;
wire C, N, Z;
wire trap, time_compare;
wire [XLEN-1:0] ADDR;

//csr wires
wire [XLEN-1:0] mstatus;
wire [XLEN-1:0] mie;
wire [XLEN-1:0] mip;
wire [XLEN-1:0] mepc;
wire [XLEN-1:0] mcause;
wire [XLEN-1:0] mbadaddr;
wire [XLEN-1:0] mtvec;
wire [FLEN-1:0] fcsr;

wire [6:0] Imm_funct = I_Imm[11:5];
wire [4:0] reduced_Imm = I_Imm[4:0];

assign opcode = IR[6:0];
assign rd = IR[11:7];
assign funct3 = IR[14:12];
assign rs1  = IR[19:15];
assign rs2 = IR[24:20];
assign rs3 = IR[31:27];
assign funct7 = IR[31:25];
assign I_Imm = IR[31:20];
assign S_Imm = {IR[31:25], IR[11:7]};
assign B_Imm = {IR[31],IR[31], IR[31], IR[7], IR[30:25], IR[11:9]}; //word addressable but instructions assume byte addressability so logic is done here
assign UJ_Imm = {IR[31], IR[19:12], IR[20], IR[30:21], 1'b0};
assign U_Imm = {IR[31:12]};

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

parameter fetch = 3'b000,mem_wait = 3'b001, decode = 3'b010,  exec = 3'b011, access = 3'b100, write_back = 3'b101, fexec = 3'b110;

// Control FSM flip-flops
// State Register
always @(posedge clk)
  if (!resetn) Tstep_Q <= fetch;
  else Tstep_Q <= Tstep_D;

// Control FSM state table (Next State Logic). TODO move it to seperate module?
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
      if (multicycle) Tstep_D = fexec;
      else Tstep_D = access;
    end
    fexec: begin
      if (~multicycle) Tstep_D = access;
      else Tstep_D = fexec;
    end
    access: begin
      Tstep_D = write_back;
    end
    write_back: begin  // instructions end after this time step
      Tstep_D = fetch;
    end
    default: Tstep_D = 3'bxxx;
  endcase


parameter R_type = 7'b0110011, I_type_1=7'b0000011, I_type_2 = 7'b0010011;
parameter SB_type = 7'b1100111, S_type = 7'b0100011, U_type = 7'b0110111, UJ_type=7'b1101111, U2_type = 7'b0010111, B_type = 7'b1100011;
parameter SYSTEM_type = 7'b1110011;
parameter FLW_type = 7'b0000111, FSW_type = 7'b0100111, FMADD_type = 7'b1000011, FMSUB_type = 7'b1000111,
    FNMSUB_type = 7'b1001011, FNMADD_type = 7'b1001111, F_type = 7'b1010011;

//arithmetic instruction funct3
parameter SLL = 3'b001, XOR = 3'b100, SRL = 3'b101, SRA = 3'b101, OR = 3'b110, AND = 3'b111, SLT = 3'b010, SLTU = 3'b011;
parameter MUL = 3'b000, MULH = 3'b001, MULSU = 3'b010, MULU = 3'b011, DIV = 3'b100, DIVU = 3'b101, REM = 3'b110, REMU = 3'b111;

//Load types
parameter LB = 3'b000, LH = 3'b001, LW = 3'b010, LBU = 3'b100, LBHU = 3'b101;

//conditional branches
parameter beq = 3'b000, bne = 3'b001, blt = 3'b100, bge = 3'b101, bltu = 3'b110, bgeu = 3'b111;

parameter _R0 = 6'b000000, _R1 = 6'b000001, _R2 = 6'b000010, _R3 = 6'b000011, _R4 = 6'b000100, 
      _R5 = 6'b000101, _R6 = 6'b000110, _R7 = 6'b000111, _R8 = 6'b001000,  _R9 = 6'b001001,  _R10 = 6'b001010,  _R11 = 6'b001011,
        _R12 = 6'b001100,  _R13 = 6'b001101,  _R14 = 6'b001110,  _R15 = 6'b001111,  _R16 = 6'b010000,
        _R17 = 6'b010001,  _R18 = 6'b010010,  _R19 = 6'b010011,  _R20 = 6'b010100,  _R21 = 6'b010101,
          _R22 = 6'b010110,  _R23 = 6'b010111,  _R24 = 6'b011000,  _R25 = 6'b011001,  _R26 = 6'b011010,
          _R27 = 6'b011011,  _R28 = 6'b011100,  _R29 = 6'b011101,  _R30 = 6'b011110,  _R31 = 6'b011111, _PC = 6'b100000;

// Control FSM outputs TODO move it to seperate module?
always @(*) begin  // Output Logic

  // default values for control signals
  rs1_in     = 1'b0;
  rd_in = 1'b0;
  frd_in = 1'b0;
  //A_in      = 1'b0;
  G_in      = 1'b0;
  F_in      = 1'b0;
  IR_in     = 1'b0;
  dout_in   = 1'b0;
  ADDR_in   = 1'b0;
  Select1    = 6'bxxxxx;
  Select2 = 6'bxxxxx;
  Select3 = 6'bxxxxx;
  Arith = 1'b0;
  mul_arith = 1'b0;
  AddSub    = 1'b0;
  Imm = 1'b0;
  din_in = 1'b0;
  W_D       = 1'b0;
  Done      = 1'b0;
  pc_in     = 1'b0;  // default pc enable
  pc_incr   = 1'b0;
  sp_incr   = 1'b0;
  sp_decr   = 1'b0;
  branch = 1'b0;
  load = 1'b0;
  zero_extend = 1'b0;
  ret = 1'b0;
  fpSel = 1'b0;
  fBusSel = 1'b0;
  width = 2'b00;
  fop = 6'b0;
  multicycle = 1'b0;
  count_rst = 1'b0;
  count_en = 1'b1;

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
        Select1 = {2'b0, rs1[4:0]};
        Select2 = {2'b0, rs2[4:0]};
        G_in = 1'b1;

        if (funct7[0] == 1)begin //MUL instructions
          mul_arith = 1'b1;
        end
        else begin
          case (funct3)
            0: begin //add 
              if (funct7[5] == 1) AddSub = 1'b1;
            end 
            default: begin
              Arith = 1'b1;
            end

          endcase
        end
      end

      I_type_1: begin //load integer
            Imm = 1'b1;
            Select1 = {2'b0, rs1[4:0]};
            G_in = 1'b1;
            //din_in = 1'b1; //new change
      end
      
      I_type_2: begin
        Select1 = {2'b0, rs1[4:0]};
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

      S_type: begin //store 
        Select1 = {2'b0, rs2[4:0]};
        Select2 = _R0;
        dout_in = 1'b1;
      end

      UJ_type: begin
        Select1 = _PC;
        Select2 = _R0;
        G_in = 1'b1;
      end

      SB_type: begin
        case (funct3) 
          0: begin
            Select1 = _PC;
            Select2 = _R0;
            G_in = 1'b1;
          end
        endcase
      end

      U_type: begin //Load Upper Imm
        Select1 = _R0;
        Imm = 1'b1;
        G_in = 1'b1;
      end

      U2_type: begin //Load Upper Imm
        Select1 = _R0;
        Imm = 1'b1;
        G_in = 1'b1;
      end

      B_type: begin //conditional branches, do a subtraction and check the value
        Select1 = {2'b0, rs1[4:0]};
        Select2 = {2'b0, rs2[4:0]};
        F_in = 1'b1;
        //G_in = 1'b1;
        AddSub = 1'b1;
      end

      FLW_type: begin //Load float
            Imm = 1'b1;
            Select1 = {2'b0, rs1[4:0]};
            G_in = 1'b1;
            //din_in = 1'b1; //new change
      end

      F_type: begin 
        case (funct7)
          7'b0001000: begin //fmul
              Select1 = {2'b0, rs1[4:0]};
              Select2 = {2'b0, rs2[4:0]};
              fop = 2;
              fBusSel = 1'b1;
              fpSel = 1'b1;
              G_in = 1'b1;
              multicycle = 1'b1;
              count_rst = 1'b1;
          end
          7'b0001100: begin //fdiv
              Select1 = {2'b0, rs1[4:0]};
              Select2 = {2'b0, rs2[4:0]};
              fop = 3;
              fBusSel = 1'b1;
              fpSel = 1'b1;
              G_in = 1'b1;
              multicycle = 1'b1;
              count_rst = 1'b1;
          end
          7'b0101100: begin //fsqrt
              Select1 = {2'b0, rs1[4:0]};
              Select2 = {2'b0, rs2[4:0]};
              fop = 17;
              fBusSel = 1'b1;
              fpSel = 1'b1;
              G_in = 1'b1;
              multicycle = 1'b1;
              count_rst = 1'b1;
          end
          7'b0000000: begin //floating point add instruction
              Select1 = {2'b0, rs1[4:0]};
              Select2 = {2'b0, rs2[4:0]};
              fop = 0;
              fBusSel = 1'b1;
              fpSel = 1'b1;
              G_in = 1'b1;
              multicycle = 1'b1;
              count_rst = 1'b1;
          end
          7'b0000100: begin //floating point sub instruction
              Select1 = {2'b0, rs1[4:0]};
              Select2 = {2'b0, rs2[4:0]};
              fop = 1;
              fBusSel = 1'b1;
              fpSel = 1'b1;
              G_in = 1'b1;
              multicycle = 1'b1;
              count_rst = 1'b1;
          end
          7'b1010000: begin
              Select1 = {2'b0, rs1[4:0]};
              Select2 = {2'b0, rs2[4:0]};
              //fop = 4;
              fBusSel = 1'b1;
              fpSel = 1'b1;
              G_in = 1'b1;
              if (funct3 == 1) fop = 14; //flt
              if (funct3 == 0) fop = 15; //fle
              if (funct3 == 2) fop = 16; //feq
          end
          7'b0010000: begin
              Select1 = {2'b0, rs1[4:0]};
              Select2 = {2'b0, rs2[4:0]};
              //fop = 4;
              fBusSel = 1'b1;
              fpSel = 1'b1;
              G_in = 1'b1;
              if (funct3 == 0) fop = 11; //fsgnj.s
              if (funct3 == 1) fop = 12; //fsgnjn.s
              if (funct3 == 2) fop = 13; //fsgnjx.s
          end
          7'b0010100: begin
              Select1 = {2'b0, rs1[4:0]};
              Select2 = {2'b0, rs2[4:0]};
              //fop = 4;
              fBusSel = 1'b1;
              fpSel = 1'b1;
              G_in = 1'b1;
              if (funct3 == 0) fop = 9; //fmin
              if (funct3 == 1) fop = 10; //fmax
          end
          7'b1101000: begin //convert integer to float
            if (rs2 == 5'b00000) begin
              Select1 = {2'b0, rs1[4:0]};
              Select2 = _R0;
              fop = 4;
              fpSel = 1'b1;
              G_in = 1'b1;
            end
            else if (rs2 == 5'b00001) begin
              Select1 = {2'b0, rs1[4:0]};
              Select2 = _R0;
              fop = 5;
              fpSel = 1'b1;
              G_in = 1'b1;              
            end
          end
          7'b1111000: begin //move integer to float
            if (rs2 == 5'b00000) begin
              Select1 = {2'b0, rs1[4:0]};
              Select2 = _R0;
              G_in = 1'b1;
            end
          end
          7'b1110000: begin 
            if (funct3 == 3'b001) begin //fclass
              fop = 8;
              fpSel = 1'b1;
            end
            else begin
            end
            if (rs2 == 5'b00000) begin //move float to integer
              fBusSel = 1'b1;
              Select1 = {2'b0, rs1[4:0]};
              Select2 = _R0;
              G_in = 1'b1;
            end
          end
          7'b1100000: begin //fcvt.w.s TODO
            if (rs2 == 5'b00000) begin
              Select1 = {2'b0, rs1[4:0]};
              Select2 = _R0;
              fop = 6;
              fpSel = 1'b1;
              fBusSel = 1'b1;
              G_in = 1'b1;
            end
            if (rs2 == 5'b00001) begin
              Select1 = {2'b0, rs1[4:0]};
              Select2 = _R0;
              fop = 7;
              fpSel = 1'b1;
              fBusSel = 1'b1;
              G_in = 1'b1;
            end
          end
        endcase
      end

      FSW_type: begin //store floating
        Select1 = {2'b0, rs2[4:0]};
        Select2 = _R0;
        fBusSel = 1'b1;
        dout_in = 1'b1;
      end

      FMADD_type: begin
        Select1 = {2'b0, rs1[4:0]};
        Select2 = {2'b0, rs2[4:0]};
        Select3 = {2'b0, rs3[4:0]};
        fop = 18;
        fBusSel = 1'b1;
        fpSel = 1'b1;
        G_in = 1'b1;
        multicycle = 1'b1;
        count_rst = 1'b1;
      end

      FMSUB_type: begin
        Select1 = {2'b0, rs1[4:0]};
        Select2 = {2'b0, rs2[4:0]};
        Select3 = {2'b0, rs3[4:0]};
        fop = 19;
        fBusSel = 1'b1;
        fpSel = 1'b1;
        G_in = 1'b1;
        multicycle = 1'b1;
        count_rst = 1'b1;
      end

      FNMADD_type: begin
        Select1 = {2'b0, rs1[4:0]};
        Select2 = {2'b0, rs2[4:0]};
        Select3 = {2'b0, rs3[4:0]};
        fop = 20;
        fBusSel = 1'b1;
        fpSel = 1'b1;
        G_in = 1'b1;
        multicycle = 1'b1;
        count_rst = 1'b1;
      end

      FNMSUB_type: begin
        Select1 = {2'b0, rs1[4:0]};
        Select2 = {2'b0, rs2[4:0]};
        Select3 = {2'b0, rs3[4:0]};
        fop = 21;
        fBusSel = 1'b1;
        fpSel = 1'b1;
        G_in = 1'b1;
        multicycle = 1'b1;
        count_rst = 1'b1;
      end

      default: ;
    endcase
    
    fexec: //multicycle floating point instructions
      case(opcode)
        F_type:  
          case (funct7)
            7'b0000000: begin //floating point add instruction
                Select1 = {2'b0, rs1[4:0]};
                Select2 = {2'b0, rs2[4:0]};
                fop = 0;
                fBusSel = 1'b1;
                fpSel = 1'b1;
                G_in = 1'b1;
                if (fstage[4:0] == 2) multicycle = 1'b0;
                else multicycle = 1'b1;
                count_en = 1'b1;
              end
            7'b0000100: begin //floating point add instruction
                Select1 = {2'b0, rs1[4:0]};
                Select2 = {2'b0, rs2[4:0]};
                fop = 1;
                fBusSel = 1'b1;
                fpSel = 1'b1;
                G_in = 1'b1;
                if (fstage[4:0] == 2) multicycle = 1'b0;
                else multicycle = 1'b1;
                count_en = 1'b1;
              end
            7'b0001000: begin //fmul
                Select1 = {2'b0, rs1[4:0]};
                Select2 = {2'b0, rs2[4:0]};
                fop = 2;
                fBusSel = 1'b1;
                fpSel = 1'b1;
                G_in = 1'b1;
                if (fstage[4:0] == 2) multicycle = 1'b0;
                else multicycle = 1'b1;
                count_en = 1'b1;
            end
            7'b0001100: begin //fdiv
                Select1 = {2'b0, rs1[4:0]};
                Select2 = {2'b0, rs2[4:0]};
                fop = 3;
                fBusSel = 1'b1;
                fpSel = 1'b1;
                G_in = 1'b1;
                if (fstage[4:0] == 26) multicycle = 1'b0;
                else multicycle = 1'b1;
                count_en = 1'b1;
            end
            7'b0101100: begin //fsqrt
                Select1 = {2'b0, rs1[4:0]};
                Select2 = {2'b0, rs2[4:0]};
                fop = 17;
                fBusSel = 1'b1;
                fpSel = 1'b1;
                G_in = 1'b1;
                if (fstage[4:0] == 26) multicycle = 1'b0;
                else multicycle = 1'b1;
                count_en = 1'b1;
            end
          endcase

        FMADD_type: begin //floating point add instruction
          Select1 = {2'b0, rs1[4:0]};
          Select2 = {2'b0, rs2[4:0]};
          Select3 = {2'b0, rs3[4:0]};
          fop = 18;
          fBusSel = 1'b1;
          fpSel = 1'b1;
          G_in = 1'b1;
          if (fstage[4:0] == 5) multicycle = 1'b0;
          else multicycle = 1'b1;
          count_en = 1'b1;
        end

        FMSUB_type: begin //floating point add instruction
          Select1 = {2'b0, rs1[4:0]};
          Select2 = {2'b0, rs2[4:0]};
          Select3 = {2'b0, rs3[4:0]};
          fop = 19;
          fBusSel = 1'b1;
          fpSel = 1'b1;
          G_in = 1'b1;
          if (fstage[4:0] == 5) multicycle = 1'b0;
          else multicycle = 1'b1;
          count_en = 1'b1;
        end

        FNMADD_type: begin //floating point add instruction
          Select1 = {2'b0, rs1[4:0]};
          Select2 = {2'b0, rs2[4:0]};
          Select3 = {2'b0, rs3[4:0]};
          fop = 20;
          fBusSel = 1'b1;
          fpSel = 1'b1;
          G_in = 1'b1;
          if (fstage[4:0] == 5) multicycle = 1'b0;
          else multicycle = 1'b1;
          count_en = 1'b1;
        end

        FNMSUB_type: begin //floating point add instruction
          Select1 = {2'b0, rs1[4:0]};
          Select2 = {2'b0, rs2[4:0]};
          Select3 = {2'b0, rs3[4:0]};
          fop = 21;
          fBusSel = 1'b1;
          fpSel = 1'b1;
          G_in = 1'b1;
          if (fstage[4:0] == 5) multicycle = 1'b0;
          else multicycle = 1'b1;
          count_en = 1'b1;
        end

      endcase


    access:  // define signals access
    case (opcode)
      R_type: begin
      end

      I_type_1: begin //load
            //ADDR_in = 1'b1;
            case (funct3)
            0: width = 2'b10;
            1: width = 2'b01;
            4: begin
              zero_extend = 1'b1;
              width = 2'b10;
            end
            5: begin
              zero_extend = 1'b1;
              width = 2'b01;
            end
            default: width = 2'b00;
            endcase
            load = 1'b1;
            G_in = 1'b1;
            din_in = 1'b1;
      end
        
      I_type_2: begin
        case (funct3)
          0: begin
          end
          default: ;
        endcase
      end

      S_type: begin //store
            Imm = 1'b1;
            Select1 = {2'b0, rs1[4:0]};
            G_in = 1'b1;
            W_D = 1'b1;
      end
      
      UJ_type: begin //breaking my standard here, writing back in this cycle
        //branch = 1'b1;
        rd_in = 1'b1;
        Select1 = _PC;
        Imm = 1'b1;
        G_in = 1'b1;
      end

      SB_type: begin //breaking my standard here, writing back in this cycle
        //branch = 1'b1;
        rd_in = 1'b1;
        Select1 = rs1;
        Imm = 1'b1;
        G_in = 1'b1;
      end

      U_type: begin //Load Upper Imm
        rd_in = 1'b1;
      end

      U2_type: begin //Load Upper Imm
        rd_in = 1'b1;
      end

      B_type: begin //conditional branches, check value type
        case (funct3)
          beq: begin 
            if (Z == 1) begin
              Select1 = _PC;
              Imm = 1'b1;
              G_in = 1'b1;
            end
          end
          bne: begin 
            if (Z == 0) begin
              Select1 = _PC;
              Imm = 1'b1;
              G_in = 1'b1;
            end
          end
          blt: begin 
            if (N == 1) begin
              Select1 = _PC;
              Imm = 1'b1;
              G_in = 1'b1;
            end
          end
          bge: begin 
            if (N == 0) begin
              Select1 = _PC;
              Imm = 1'b1;
              G_in = 1'b1;
            end
          end
          bltu: begin 
            if (N == 1) begin
              Select1 = _PC;
              Imm = 1'b1;
              G_in = 1'b1;
            end
          end
          bgeu: begin 
            if (N == 0) begin
              Select1 = _PC;
              Imm = 1'b1;
              G_in = 1'b1;
            end
          end


          default: ;
        endcase
      end
      
      FLW_type: begin //load floating
            //ADDR_in = 1'b1;
            width = 2'b00;
            load = 1'b1;
            G_in = 1'b1;
            din_in = 1'b1;
      end

      FSW_type: begin //store
        Imm = 1'b1;
        Select1 = {2'b0, rs1[4:0]};
        G_in = 1'b1;
        W_D = 1'b1;
      end
    endcase

    write_back:  // define write_back
    case (opcode)
    R_type: begin
        rd_in = 1'b1;
        Done = 1'b1;
    end

    I_type_1: begin //load
          rd_in = 1'b1;
          Done = 1'b1;
          //din_in = 1'b1;
    end

    I_type_2: begin
          rd_in = 1'b1;
          Done = 1'b1;
      end

    S_type: begin //store 
      case (funct3)
        0: width = 2'b10;
        1: width = 2'b01;
        2: width = 2'b00;
        default:;
      endcase
          //load = 1'b1;
          //G_in = 1'b1;
          load = 1'b1;
          Done = 1'b1; 
    end
      
    UJ_type: begin //Jump and Link
      pc_in = 1'b1;
      branch = 1'b1;
      Done = 1'b1;
    end

    SB_type: begin //Jump and Link Reg
      pc_in = 1'b1;
      branch = 1'b1;
      Done = 1'b1;
    end

      U_type: begin //Load Upper Imm
        Done = 1'b1;
      end

      U2_type: begin //Load Upper Imm
        Done = 1'b1;
      end

      B_type: begin //conditional branches
        case (funct3)
          beq: begin 
            if (Z == 1) begin
              pc_in = 1'b1;
              branch = 1'b1;
              Done = 1'b1;
            end
          end
          bne: begin 
            if (Z == 0) begin
              pc_in = 1'b1;
              branch = 1'b1;
              Done = 1'b1;
            end
          end
          blt: begin 
            if (N == 1) begin
              pc_in = 1'b1;
              branch = 1'b1;
              Done = 1'b1;
            end
          end
          bge: begin 
            if (N == 0) begin
              pc_in = 1'b1;
              branch = 1'b1;
              Done = 1'b1;
            end
          end
          bltu: begin 
            if (N == 1) begin
              pc_in = 1'b1;
              branch = 1'b1;
              Done = 1'b1;
            end
          end
          bgeu: begin 
            if (N == 0) begin
              pc_in = 1'b1;
              branch = 1'b1;
              Done = 1'b1;
            end
          end
          default: ;
        endcase
      end
    SYSTEM_type: begin
      pc_in = 1'b1;
      ret = 1'b1;
      Done = 1'b1;
    end
    F_type: begin //for both move and fcvt this remains correct
      Done = 1'b1;
        
      case(funct7)
        7'b0101100: begin
          frd_in = 1'b1;
        end
        7'b0001100: begin
          frd_in = 1'b1;
        end
        7'b0001000: begin
          frd_in = 1'b1;
        end
        7'b0000100: begin
          frd_in = 1'b1;
        end
        7'b0000000: begin
          frd_in = 1'b1;
        end
        7'b1010000: begin
          frd_in = 1'b1;
        end
        7'b0010000: begin
          frd_in = 1'b1;
        end
        7'b0010100: begin
          frd_in = 1'b1;
        end
        7'b1101000: begin
          frd_in = 1'b1;
        end
        7'b1111000: begin
          frd_in = 1'b1;
        end
        7'b1110000: begin 
          rd_in = 1'b1;
        end
        7'b1100000: begin
          rd_in = 1'b1;
        end
      endcase
    end

    FLW_type: begin //load floating
      frd_in = 1'b1;
      Done = 1'b1;
      //din_in = 1'b1;
    end

    FMADD_type: begin
      frd_in = 1'b1;
      Done = 1'b1;
    end

    FMSUB_type: begin
      frd_in = 1'b1;
      Done = 1'b1;
    end

    FNMADD_type: begin
      frd_in = 1'b1;
      Done = 1'b1;
    end

    FNMSUB_type: begin
      frd_in = 1'b1;
      Done = 1'b1;
    end

    FSW_type: begin //store 
      width = 2'b00;
      //load = 1'b1;
      //G_in = 1'b1;
      load = 1'b1;
      Done = 1'b1; 
    end
    default: ;
  endcase
  endcase
end

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
    .R_in			(R_in[31:0]), //must be in order?? 
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
		 .R_in			(Fp_in[31:0]), //must be in order?? 
		 .clk			(clk));

//multicycle counter
counter fstage0 (
  .clk(clk),
  .resetn(resetn & ~count_rst),
  .enable(count_en),
  .out(fstage)
);

// program counter
pc_count reg_pc (
    .D(PCSrc),
    .resetn(resetn),
    .clk(clk),
    .En(pc_incr),
    .PLoad(pc_in | trap),
    .Q(pc)
);

regn reg_dout (
    .D(Sum),
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

always@(*) //memory being tested is word addressable and the convertion is being don in the 
  if (load) realaddr = (G);
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

//pc logic unit
always @(*)
if (ret) PCSrc = mepc;
else if (!trap) begin
  if (branch) PCSrc = G; 
  else PCSrc = pc + 4;
end
else begin
  PCSrc = mtvec;
end
always@(*)
  if (fpSel) begin
    Sum = fSum;
  end
  else begin
    case(width)
    2'b00: Sum = Sum_full;
    2'b01: begin
      if (!zero_extend) Sum = {{16{Sum_half[15]}},Sum_half};
      else Sum = {16'b0,Sum_half};
    end
    2'b10: begin
      if (!zero_extend) Sum = {{24{Sum_byte[7]}},Sum_byte};
      else Sum = {24'b0,Sum_byte};
    end
    default: Sum = 2'bxx;
    endcase
  end
// alu TODO seperate into own module

assign product = $unsigned(BusWires1) * $unsigned(BusWires2);
assign sproduct = $signed(BusWires1) * $signed(BusWires2);
assign suproduct = $signed(BusWires1) * $unsigned(BusWires2);

always @(*)

  if (din_in) Sum_full = din;
  else if (mul_arith) 
    case (funct3)
      MUL: {ALU_Cout, Sum_full} = sproduct[32:0];
      MULH:{ALU_Cout, Sum_full} = sproduct[64:32];
      MULSU:{ALU_Cout, Sum_full} = suproduct[32:0];
      MULU: {ALU_Cout, Sum_full} = product[32:0];
      DIV: {ALU_Cout, Sum_full} = $signed(BusWires1) / $signed(BusWires2);
      DIVU: {ALU_Cout, Sum_full} = $unsigned(BusWires1) / $unsigned(BusWires2);
      REM: {ALU_Cout, Sum_full} = $signed(BusWires1) % $signed(BusWires2);
      REMU: {ALU_Cout, Sum_full} = $unsigned(BusWires1) % $unsigned(BusWires2);
      default: ;
    endcase
  else if (Arith) //set of R-type non-add arithmetic instructions
    case (funct3)
      SLL: begin
        if (opcode == R_type)  {ALU_Cout, Sum_full} = BusWires1 << BusWires2;
        else  {ALU_Cout, Sum_full} = BusWires1 << reduced_Imm;
      end
      SRL: begin
        if (opcode == R_type) begin
          case (funct7)
            0: {ALU_Cout, Sum_full} = BusWires1 >> BusWires2;
            8'h20:  {ALU_Cout, Sum_full} = {BusWires1[31],$signed(BusWires1 >>> BusWires2)};
            default:;
          endcase
        end
        
        else begin
        case (Imm_funct)
          0: {ALU_Cout, Sum_full} = BusWires1 >> reduced_Imm;
          7'h20:  {ALU_Cout, Sum_full} = {BusWires1[31],BusWires1 >>> reduced_Imm};
          default:;
        endcase
      end
      end
      SLT: {ALU_Cout, Sum_full} = ($signed(BusWires1) < $signed(BusWires2)) ? 32'b1: 32'b0;
      SLTU: {ALU_Cout, Sum_full} = ($unsigned(BusWires1) < $unsigned(BusWires2)) ? 32'b1: 32'b0;
      XOR: {ALU_Cout, Sum_full} = BusWires1 ^ BusWires2;
      OR: {ALU_Cout, Sum_full} = BusWires1 | BusWires2;
      AND: {ALU_Cout, Sum_full} = BusWires1 & BusWires2;
    endcase
  else if (AddSub) {ALU_Cout, Sum_full} = BusWires1 + ~BusWires2 + 32'b1; //sub
  else if (opcode == U_type) begin //don't like this, TODO change into acceptable form
    {ALU_Cout, Sum_full} = {{BusWires2[19]},BusWires2 << 12};
  end
  else if (opcode == U2_type) begin //don't like this, TODO change into acceptable form
    {ALU_Cout, Sum_full} = (BusWires2 << 12) + pc-4;
  end
  else {ALU_Cout, Sum_full} = BusWires1 + BusWires2; //add

//FPU
fpu ex1(
  .clk(clk),
  .resetn(resetn),
  .operation(fop),
  .rs1(BusWires1),
  .rs2(BusWires2),
  .rs3(BusWires3),
  .fcsr(fcsr),
  .result(fSum)

);

regn reg_G (
    .D(Sum),
    .resetn(resetn),
    .En(G_in),
    .clk(clk),
    .Q(G)
);

// define the internal processor bus
always @(*)
  if (fBusSel == 1'b1) begin
    case (Select1)
      _R0: BusWires1 = f0;
      _R1: BusWires1 = f1;
      _R2: BusWires1 = f2;
      _R3: BusWires1 = f3;
      _R4: BusWires1 = f4;
      _R5: BusWires1 = f5;
      _R6: BusWires1 = f6;
      _R7: BusWires1 = f7;
      _R8: BusWires1 = f8;
      _R9: BusWires1 = f9;
      _R10: BusWires1 = f10;
      _R11: BusWires1 = f11;
      _R12: BusWires1 = f12;
      _R13: BusWires1 = f13;
      _R14: BusWires1 = f14;
      _R15: BusWires1 = f15;
      _R16: BusWires1 = f16;
      _R17: BusWires1 = f17;
      _R18: BusWires1 = f18;
      _R19: BusWires1 = f19;
      _R20: BusWires1 = f20;
      _R21: BusWires1 = f21;
      _R22: BusWires1 = f22;
      _R23: BusWires1 = f23;
      _R24: BusWires1 = f24;
      _R25: BusWires1 = f25;
      _R26: BusWires1 = f26;
      _R27: BusWires1 = f27;
      _R28: BusWires1 = f28;
      _R29: BusWires1 = f29;
      _R30: BusWires1 = f30;
      _R31: BusWires1 = f31;
      _PC: BusWires1 = pc-4; //pc has been incremented we want to select the old one (will have to change in pipelined)
      //_G: BusWires1
      default: BusWires1 = 32'bx;
    endcase
  end
  else begin
    case (Select1)
      _R0: BusWires1 = r0;
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
      _PC: BusWires1 = pc-4; //pc has been incremented we want to select the old one (will have to change in pipelined)
      //_G: BusWires1
      default: BusWires1 = 32'bx;
    endcase
  end

  always @(*)
  if (Imm) begin
    case (opcode) 
      I_type_1: BusWires2 = {{21{I_Imm[11]}},I_Imm}; 
      I_type_2: BusWires2 = {{21{I_Imm[11]}},I_Imm};
      S_type: BusWires2 = {21'b0, S_Imm};
      UJ_type: BusWires2 = {{12{UJ_Imm[20]}},UJ_Imm};
      SB_type: BusWires2 = {{21{I_Imm}},I_Imm};
      U_type: BusWires2 = {{12{U_Imm}},U_Imm};
      U2_type: BusWires2 = {{12{U_Imm}},U_Imm};
      FLW_type: BusWires2 = {{21{I_Imm[11]}},I_Imm};
      FSW_type: BusWires2 = {21'b0, S_Imm};
      B_type: begin
        if ((funct3 == 3'b110) | (funct3 == 3'b111)) BusWires2 = {21'b0, B_Imm};
        else BusWires2 = {{21{B_Imm[11]}}, B_Imm};
      end
      default: ;
    endcase
  end
  else begin
    if (fBusSel == 1'b1) begin
        case (Select2)
        _R0: BusWires2 = f0;
        _R1: BusWires2 = f1;
        _R2: BusWires2 = f2;
        _R3: BusWires2 = f3;
        _R4: BusWires2 = f4;
        _R5: BusWires2 = f5;
        _R6: BusWires2 = f6;
        _R7: BusWires2 = f7;
        _R8: BusWires2 = f8;
        _R9: BusWires2 = f9;
        _R10: BusWires2 = f10;
        _R11: BusWires2 = f11;
        _R12: BusWires2 = f12;
        _R13: BusWires2 = f13;
        _R14: BusWires2 = f14;
        _R15: BusWires2 = f15;
        _R16: BusWires2 = f16;
        _R17: BusWires2 = f17;
        _R18: BusWires2 = f18;
        _R19: BusWires2 = f19;
        _R20: BusWires2 = f20;
        _R21: BusWires2 = f21;
        _R22: BusWires2 = f22;
        _R23: BusWires2 = f23;
        _R24: BusWires2 = f24;
        _R25: BusWires2 = f25;
        _R26: BusWires2 = f26;
        _R27: BusWires2 = f27;
        _R28: BusWires2 = f28;
        _R29: BusWires2 = f29;
        _R30: BusWires2 = f30;
        _R31: BusWires2 = f31;
        default: BusWires2 = 32'bx;
      endcase
    end
    else begin
      case (Select2)
        _R0: BusWires2 = r0;
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
  end

  always@(*)
    case (Select3)
      _R0: BusWires3 = f0;
      _R1: BusWires3 = f1;
      _R2: BusWires3 = f2;
      _R3: BusWires3 = f3;
      _R4: BusWires3 = f4;
      _R5: BusWires3 = f5;
      _R6: BusWires3 = f6;
      _R7: BusWires3 = f7;
      _R8: BusWires3 = f8;
      _R9: BusWires3 = f9;
      _R10: BusWires3 = f10;
      _R11: BusWires3 = f11;
      _R12: BusWires3 = f12;
      _R13: BusWires3 = f13;
      _R14: BusWires3 = f14;
      _R15: BusWires3 = f15;
      _R16: BusWires3 = f16;
      _R17: BusWires3 = f17;
      _R18: BusWires3 = f18;
      _R19: BusWires3 = f19;
      _R20: BusWires3 = f20;
      _R21: BusWires3 = f21;
      _R22: BusWires3 = f22;
      _R23: BusWires3 = f23;
      _R24: BusWires3 = f24;
      _R25: BusWires3 = f25;
      _R26: BusWires3 = f26;
      _R27: BusWires3 = f27;
      _R28: BusWires3 = f28;
      _R29: BusWires3 = f29;
      _R30: BusWires3 = f30;
      _R31: BusWires3 = f31;
      _PC: BusWires3 = pc-4; //pc has been incremented we want to select the old one (will have to change in pipelined)
      //_G: BusWires3
      default: BusWires3 = 32'bx;
    endcase

regn #(
    .n(3)
) reg_F (
    .D({ALU_Cout, Sum[31], (Sum == 0)}),
    .resetn(resetn),
    .clk(clk),
    .En(F_in),
    .Q({C, N, Z})
);

csr csr_inst(
  .clk(clk),
  .resetn(resetn),
  .csr_addr(realaddr),
  .data_in(dout),
  .done(Done),
  .write_en(W),
  .mstatus(mstatus),
  .mie(mie),
  .mip(mip),
  .mepc(mepc),
  .mcause(mcause),
  .mbadaddr(mbadaddr),
  .mtvec(mtvec),
  .time_compare(time_compare),
  .fcsr(fcsr),
  .csr_readbus()
);

interrupt_ctrl interrupt_ctrl_inst(
  .clk(clk),
  .pc(pc),
  .ret(ret),
  .mstatus(mstatus),
  .mie(mie),
  .mip(mip),
  .mcause(mcause),
  .mbadaddr(mbadaddr),
  .mepc(mepc),
  .trap(trap),
  //.done(Done),
  .Tstep_Q(Tstep_Q),
  .addr(realaddr),
  .load(load),
  .W(W),
  .resetn(resetn),
  .time_compare(time_compare),
  .opcode(opcode),
  .Sum(Sum),
  .G(G)
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
  else if (En) Q <= Q + 'h4;
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
  else if (Up) Q <= Q + 'h4;
  else if (Down) Q <= Q - 'h4;
endmodule

module dec3to8 (
  input wire En,  // enable
  input wire [4:0] W,
  output reg [31:0] Y
);
always @(*)
  if (!En) Y = 11'b00000000;
  else
    case (W) 
      5'b00000: Y = 32'b00000000000000000000000000000001;
      5'b00001: Y = 32'b00000000000000000000000000000010;
      5'b00010: Y = 32'b00000000000000000000000000000100;
      5'b00011: Y = 32'b00000000000000000000000000001000;
      5'b00100: Y = 32'b00000000000000000000000000010000;
      5'b00101: Y = 32'b00000000000000000000000000100000;
      5'b00110: Y = 32'b00000000000000000000000001000000;
      5'b00111: Y = 32'b00000000000000000000000010000000;
      5'b01000: Y = 32'b00000000000000000000000100000000;
      5'b01001: Y = 32'b00000000000000000000001000000000;
      5'b01010: Y = 32'b00000000000000000000010000000000;
      5'b01011: Y = 32'b00000000000000000000100000000000;
      5'b01100: Y = 32'b00000000000000000001000000000000;
      5'b01101: Y = 32'b00000000000000000010000000000000;
      5'b01110: Y = 32'b00000000000000000100000000000000;
      5'b01111: Y = 32'b00000000000000001000000000000000;
      5'b10000: Y = 32'b00000000000000010000000000000000;
      5'b10001: Y = 32'b00000000000000100000000000000000;
      5'b10010: Y = 32'b00000000000001000000000000000000;
      5'b10011: Y = 32'b00000000000010000000000000000000;
      5'b10100: Y = 32'b00000000000100000000000000000000;
      5'b10101: Y = 32'b00000000001000000000000000000000;
      5'b10110: Y = 32'b00000000010000000000000000000000;
      5'b10111: Y = 32'b00000000100000000000000000000000;
      5'b11000: Y = 32'b00000001000000000000000000000000;
      5'b11001: Y = 32'b00000010000000000000000000000000;
      5'b11010: Y = 32'b00000100000000000000000000000000;
      5'b11011: Y = 32'b00001000000000000000000000000000;
      5'b11100: Y = 32'b00010000000000000000000000000000;
      5'b11101: Y = 32'b00100000000000000000000000000000;
      5'b11110: Y = 32'b01000000000000000000000000000000;
      5'b11111: Y = 32'b10000000000000000000000000000000;
      default: Y = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
    endcase
endmodule
