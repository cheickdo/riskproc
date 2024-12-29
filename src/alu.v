module alu(
    input [6:0] opcode,
    input [5:0] funct3,
    input [6:0] funct7,
    input [31:0] BusWires1,
    input [31:0] BusWires2,
    input data_out_valid,
    input [6:0] Imm_funct,
    output reg Sum,
    output reg Sum_valid
);

reg [31:0] Sum_full;
reg [15:0] Sum_half;
reg ALU_Cout;

//opcode types
parameter R_type = 7'b0110011, I_type_1=7'b0000011, I_type_2 = 7'b0010011;
parameter SB_type = 7'b1100111, S_type = 7'b0100011, U_type = 7'b0110111, UJ_type=7'b1101111, U2_type = 7'b0010111, B_type = 7'b1100011;
parameter SYSTEM_type = 7'b1110011;
parameter FLW_type = 7'b0000111, FSW_type = 7'b0100111, FMADD_type = 7'b1000011, FMSUB_type = 7'b1000111,
    FNMSUB_type = 7'b1001011, FNMADD_type = 7'b1001111, F_type = 7'b1010011;

always@(*) begin
  case (opcode)
        R_type: begin
          Select1 = {1'b0, rs1[4:0]};
          Select2 = {1'b0, rs2[4:0]};
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
        
        I_type_2: begin
          Select1 = {1'b0, rs1[4:0]};
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
            default: ;
          endcase
        end

        U_type: begin //Load Upper Imm
          Select1 = _R0;
          Imm = 1'b1;
          G_in = 1'b1;
          u_op = 1'b1;
        end

        U2_type: begin //Load Upper Imm
          Select1 = _R0;
          Imm = 1'b1;
          G_in = 1'b1;
        end

        B_type: begin //conditional branches, do a subtraction and check the value
          Select1 = {1'b0, rs1[4:0]};
          Select2 = {1'b0, rs2[4:0]};
          F_in = 1'b1;
          //G_in = 1'b1;
          AddSub = 1'b1;
        end

        default: ;
      endcase
  end

always@(*)
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
        default: Sum = 32'b00;
    endcase
// ALU TODO seperate into own module

assign product = $unsigned(BusWires1) * $unsigned(BusWires2);
assign sproduct = $signed(BusWires1) * $signed(BusWires2);
assign suproduct = $signed(BusWires1) * $unsigned(BusWires2);

always @(*) begin
  Sum_full = 32'b0;
  ALU_Cout = 1'b0;

  casez ({din_in, mul_arith, Arith, AddSub, u_op, u2_op})
    6'b01????:
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
    6'b001???: //set of R-type non-add arithmetic instructions
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
              0: {ALU_Cout, Sum_full} = BusWires1 >> BusWires2[4:0];
              7'h20:  {ALU_Cout, Sum_full} = {BusWires1[31],BusWires1 >>> BusWires2[4:0]};
              default:;
            endcase
          end
        end
        SLT: {ALU_Cout, Sum_full} = ($signed(BusWires1) < $signed(BusWires2)) ? 32'b1: 32'b0;
        SLTU: {ALU_Cout, Sum_full} = ($unsigned(BusWires1) < $unsigned(BusWires2)) ? 32'b1: 32'b0;
        XOR: {ALU_Cout, Sum_full} = BusWires1 ^ BusWires2;
        OR: {ALU_Cout, Sum_full} = BusWires1 | BusWires2;
        AND: {ALU_Cout, Sum_full} = BusWires1 & BusWires2;
        default: ;
      endcase
    6'b0001??: {ALU_Cout, Sum_full} = {BusWires1[31], BusWires1} + {~BusWires2[31],~BusWires2} + 1; //sub
    6'b00001?: {ALU_Cout, Sum_full} = {{BusWires2[19]},BusWires2 << 12};
    6'b000001: {ALU_Cout, Sum_full} = (BusWires2 << 12) + pc-4;
    default : {ALU_Cout, Sum_full} = BusWires1 + BusWires2; //add
  endcase
end

endmodule