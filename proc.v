//32-bit RISC-V standalone processor

module proc();
endmodule

module control(DIN, resetn, clock, run, DOUT, ADDR, W);
	input [31:0] DIN;
    input resetn, clock, run;
    output wire [31:0] DOUT;
    output wire [31:0] ADDR;
    output wire W;

	wire [31:0] IR;

    //fields
    wire [6:0] r_funct7, opcode;
    wire [4:0] r_rs1, r_rs2, r_rd, i_rs1, i_rd;
    wire [2:0] i_funct3, r_funct3;
    wire [11:0] immediate;

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
	/* OPCODE instructions found within the excel

    */
endmodule

//governs ALU
module datapath(BusWires, AddSub, Cout, Sum);
    
    wire [31:0] BusWires;
    wire [31:0] Sum;
    wire [31:0] Cout;

    //control signals
    wire AddSub;

    //ALU
    always @(*) begin
        if (AddSub) {Cout, Sum} = A + ~BusWires + 16'b1;
        else {Cout, Sum} = A + BusWires;
    end
endmodule

//32-bit register
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