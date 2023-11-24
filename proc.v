//32-bit RISC-V standalone processor modules

module control(
	input wire[31:0] DIN,
    input wire resetn,
    input wire clock,
    input wire run,
    output wire [31:0] BusWires,
    output wire [31:0] DOUT,
    output wire [31:0] ADDR,
    output wire [2:0] T_D,
    output wire W
);

    //FSM state & IR
	wire [31:0] IR;
    reg Done;
    reg [2:0] T_D, T_Q;

    //control signals
    reg rX_in, IR_in, ADDR_in, Done, DOUT_in, A_in, G_in, F_in, AddSub, ALU_and, ALU_shift;
    reg [4:0] sel; 
    reg pc_incr;  // used to increment the pc
    reg sp_incr, sp_decr;
    reg sp_in, lr_in, pc_in;  // used to load the sp, lr, pc
    reg  W_D;  // used for write signal

    //fields
    wire [6:0] r_funct7, opcode;
    wire [4:0] r_rs1, r_rs2, r_rd, i_rs1, i_rd;
    wire [2:0] i_funct3, r_funct3;
    wire [11:0] immediate;

    wire [6:0] r_sign,ld_sign,sd_sign,beq_sign;

    //bus multiplexor
    parameter r0 = 5'b00000, r1 = 5'b00001, r2 = 5'b00010, r3 = 5'b00011, r4 = 5'b00100, r5 = 5'b00101,
        r6 = 5'b00110, r7 = 5'b00111, r8 = 5'b01000, r9 = 5'b01001, r10 = 5'b01010, r11 = 5'b01011,
        r12 = 5'b01100 , r13 = 5'b01101, r14 = 5'b01110, r15 = 5'b01111, r16 = 5'b10000, 
        r17 = 5'b10001, r18 = 5'b10010, r19 = 5'b10011, r20 = 5'b10100, r21 = 5'b10101,
        r22 = 5'b10110, r23 = 5'b10111, r24 = 5'b11000, r25 = 5'b11001, r26 = 5'b11010, 
        r27 = 5'b11011, r28 = 5'b11100 , r29 = 5'b11101, r30 = 5'b11110, r31 = 5'b11111; 

    /* Stages */
    parameter fetch = 3'b000, decode_0 = 3'b001, decode_1 = 3'b010, exec = 3'b011, access = 3'b100, write = 3'b101;

    //control signals depending on instruction type
    /*
        In the form {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp1, ALUOp0}
    */
    assign r_sign = 7'b00100010;
    assign ld_sign = 7'11110000;
    assign r_sign = 7'1x001000;
    assign r_sign = 7'0x000101;


    //instruction format encodings 
    assign opcode = IR[6:0];
    assign rd = IR[11:7];
    assign funct7 = IR[31:25];
    assign rs1 = IR[19:15];
    assign rs2 = IR[24:20];
    assign funct3 = IR[14:12];
    assign S_imm = {IR[31:25], IR[11:7]};
    assign SB_imm = {IR[12], IR[10:5], IR[4:1], IR[11]};
    assign I_imm = IR[31:20];
    assign UJ_imm = {IR[20], IR[10:1], IR[11], IR[19:12]}
    assign U_imm = {IR[31:12]}

    //instruction encodings {opcode, funct3, funct6/7}
    //R-type
    assign add = 17'b01100110000000000
    assign sub = 17'b01100110000100000
    assign sll = 17'b01100110010000000
    assign XOR = 17'b01100111000000000
    assign srl = 17'b01100111010000000
    assign sra = 17'b01100111010000000
    assign OR = 17'b01100111100000000
    assign AND = 17'b01100111110000000
    assign lr.d = 17'b01100110110001000
    assign sc.d = 17'b01100110110001100

    //I-type
    assign ld = 10'b0000011000
    assign lh = 10'b0000011001
    assign iw = 10'b0000011010
    assign id = 10'b0000011011
    assign ibu = 10'b0000011100
    assign ihu = 10'b0000011101
    assign iwu = 10'b0000011110
    assign addi = 10'b0010011000
    assign slli = 17'b00100110010000000
    assign xori = 10'b0010011100
    assign srli = 17'b00100111010000000
    assign srai = 17'b00100111010100000
    assign or1 = 10'b0010011110
    assign andi = 10'b0010011111
    assign jalr = 10'b1100111000

    // S-type
    assign sb = 10'b0100011000
    assign sh = 10'b0100011001
    assign sw = 10'b0100011010
    assign sd = 10'b0010011111

    //SB-type
    assign beq = 10'b1100111000
    assign bne = 10'b1100111001
    assign blt = 10'b1100111100
    assign bge = 10'b1100111101
    assign bltu = 10'b1100111110
    assign bgeq = 10'b1100111111

    //U-type
    assign lui = 7'b0110111
    
    //UJ-type
    assign jal = 7'b1101111

    /*Note: 
    register x0 is harwired to value 0
    register x1 is PC(or link register)
    register x2 is sp
    register x3 is global pointer(gp)
    register x4 is thread pointer(tp)
    register x8 frame pointer
    */

    //FSM controlling instruction clock cycles, rewrite it to be pipelined
    always @(*)
        case (T_Q)
        T0: begin  // instruction fetch
            if (~Run) T_D = fetch;
            else T_D = decode;
        end
        T1: begin  // instruction decode
            T_D = exec;
        end
        T2: begin  // execute instruction
            T_D = access;
        end
        T3: begin //access memory
            if (Done) T_D = fetch;
            else T_D = write;
        end
        T4: begin //write-back
            T_D = fetch;
        end
        default: T_D = 3'bxxx;
        endcase

    //Main control FSM outputs
    always @(*) begin
        //default values
        rX_in = 1'b0;
        A_in = 1'b0;
        G_in = 1'b0;
        F_in = 1'b0;
        IR_in = 1'b0;
        DOUT_in = 1'b0;
        ADDR_in = 1'b0;
        sel = 5'bxxxxx;
        AddSub = 1'b0;
        ALU_and = 1'b0;
        ALU_shift = 1'b0;
        W_D = 1'b0;
        Done = 1'b0;
        sp_in = R_in[5];
        lr_in = R_in[6];
        pc_in = R_in[7];
        pc_incr = 1'b0;
        //sp_incr = 1'b0;
        //sp_decr = 1'b0;

        case (T_Q)
            fetch: begin
                sel = pc; //puts pc on bus
                ADDR_in = 1;
                pc_incr = Run; //increments pc
            end
            decode_0: begin
                //do nothing and wait for memory cycle, instruction decode is done combinatorially
            end
            decode_1: begin
            end
            exec: begin

            end
            access: begin
            end
            write: begin
            end
        endcase

    end
    

    //instruction decode
    always @(*) begin
        
    end
    
    //Control FF's
    always @(posedge Clock) begin
        if (!resetn) T_Q <= T0;
        else T_Q <= T_D;
    end
endmodule

//governs ALU
module datapath(BusWires, AddSub, Cout, Sum, PC, reg1, reg2, Zero);
    
    wire [31:0] BusWires;
    wire [31:0] Sum;
    wire [31:0] Cout;

    //controls branch control logic
    output Zero;

    //assign to Imm Gen(sign extended) << 1 added to PC
    wire [31:0] bTarget; 


    //control signals
    wire AddSub;

    //ALU
    always @(*) begin
        if (AddSub) {Cout, Sum} = A + ~BusWires + 16'b1;
        else {Cout, Sum} = A + BusWires;
    end

    /*
    always @(*)
    if (ALU_shift)
      case (shift_type)
        lsl: {ALU_Cout, Sum} = A << BusWires[3:0];
        lsr: {ALU_Cout, Sum} = A >> BusWires[3:0];
        asr: {ALU_Cout, Sum} = {{16{A[15]}}, A} >> BusWires[3:0];
        ror: {ALU_Cout, Sum} = (A >> BusWires[3:0]) | (A << (16 - BusWires[3:0]));
      endcase
    else if (ALU_and) {ALU_Cout, Sum} = A & BusWires;
    else if (AddSub) {ALU_Cout, Sum} = A + ~BusWires + 16'b1;
    else {ALU_Cout, Sum} = A + BusWires;
    */

endmodule

//32-bit general register
module regn #(parameter n = 32) (D, Resetn, E, Clock, Q);
    input wire [n-1:0] D;
    input wire Resetn;
    input wire E;
    input wire Clock;
    output reg [n-1:0] Q;
    
    always @(posedge Clock)
        if (!Resetn) Q <= 0;
        else if (E) Q <= D;
endmodule