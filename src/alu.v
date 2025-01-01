module alu #(parameter DATA_WIDTH=32) (
    input clk, resetn,
    input [6:0] opcode,
    input [5:0] funct3,
    input [6:0] funct7,
    input [4:0] reduced_Imm,
    input [DATA_WIDTH-1:0] BusWires1,
    input [DATA_WIDTH-1:0] BusWires2,
    input data_out_valid,
    input [6:0] Imm_funct,
    output [DATA_WIDTH-1:0] Sum,
    output reg Sum_valid
);

reg [31:0] Sum_full;
reg [15:0] Sum_half;
reg ALU_Cout;
wire [64:0] sproduct;
wire [64:0] product;
wire [64:0] suproduct;

reg din_in, mul_arith, Arith, AddSub, u_op, u2_op;

assign Sum = Sum_full;

//Valid mux
always@(posedge clk) begin
  if (!resetn) begin
    Sum_valid = 1'b0;
  end
  else if (data_out_valid) begin
    Sum_valid = 1'b1;
  end
  else begin
    Sum_valid = 1'b0;
  end
end

//arithmetic instruction funct3
parameter SLL = 3'b001, XOR = 3'b100, SRL = 3'b101, SRA = 3'b101, OR = 3'b110, AND = 3'b111, SLT = 3'b010, SLTU = 3'b011;
parameter MUL = 3'b000, MULH = 3'b001, MULSU = 3'b010, MULU = 3'b011, DIV = 3'b100, DIVU = 3'b101, REM = 3'b110, REMU = 3'b111;


//opcode types
parameter R_type = 7'b0110011, I_type_1=7'b0000011, I_type_2 = 7'b0010011;
parameter SB_type = 7'b1100111, S_type = 7'b0100011, U_type = 7'b0110111, UJ_type=7'b1101111, U2_type = 7'b0010111, B_type = 7'b1100011;
parameter SYSTEM_type = 7'b1110011;
parameter FLW_type = 7'b0000111, FSW_type = 7'b0100111, FMADD_type = 7'b1000011, FMSUB_type = 7'b1000111,
    FNMSUB_type = 7'b1001011, FNMADD_type = 7'b1001111, F_type = 7'b1010011;

always@(*) begin
  din_in = 1'b0;
  mul_arith = 1'b0;
  Arith = 1'b0;
  AddSub = 1'b0;
  u_op = 1'b0;
  u2_op = 1'b0;

  case (opcode)
        R_type: begin

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
          case (funct3)
            0: begin //add is default
            end
            default: begin
              Arith = 1'b1;
            end

          endcase
        end

        UJ_type: begin
        end

        SB_type: begin
          case (funct3) 
            default: ;
          endcase
        end

        U_type: begin //Load Upper Imm
          u_op = 1'b1;
        end

        U2_type: begin //Load Upper Imm
        end

        B_type: begin //conditional branches, do a subtraction and check the value
          //F_in = 1'b1;
          //G_in = 1'b1;
          AddSub = 1'b1;
        end

        default: ;
      endcase
  end

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
    //6'b000001: {ALU_Cout, Sum_full} = (BusWires2 << 12) + pc-4; //Figure out how to get pc in OoO processing
    default : {ALU_Cout, Sum_full} = BusWires1 + BusWires2; //add
  endcase
end

// Dump waves
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, alu);
end

endmodule