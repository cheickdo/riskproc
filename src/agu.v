module agu #(parameter DATA_WIDTH=32) (
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
reg ALU_Cout;

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

always @(*) 
    {ALU_Cout, Sum_full} = BusWires1 + BusWires2; //add

// Dump waves
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, alu);
end

endmodule