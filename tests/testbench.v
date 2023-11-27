`timescale 1ns / 1ps

module testbench ( );

	parameter CLOCK_PERIOD = 20;

	reg [31:0] Instruction;
	reg Run;
	wire [31:0] DOUT;
	wire [31:0] ADDR;
	wire W;

	reg CLOCK_50;
	initial begin
		CLOCK_50 <= 1'b0;
	end // initial
	always @ (*)
	begin : Clock_Generator
		#((CLOCK_PERIOD) / 2) CLOCK_50 <= ~CLOCK_50;
	end
	
	reg Resetn;
	initial begin
		Resetn <= 1'b0;
		#20 Resetn <= 1'b1;
	end // initial

	initial begin
				Run	<= 1'b0;	Instruction	<= 32'b00000000000100000000000010010011;	
		#20	Run	<= 1'b1; Instruction	<= 32'b00000000000100000000000010010011; // addi  r1, #1	
		#120	Run	<= 1'b1; Instruction	<= 32'b00000000001000000000000000010011; // addi r0, #2
		#120	Run	<= 1'b1; Instruction	<= 32'b00000000000100000000000100110011; // add r0, r1 to r2
		#120	Run	<= 1'b1; Instruction	<= 32'b01000000000100000000000100110011; // sub r0, r1 to r2 (rs2, rs1)
		#120	Run	<= 1'b1; Instruction	<= 32'b00000000000000000101001000000001; //
		#120 Run <= 1'b0;
	end // initial

	proc U1 (Instruction, Resetn, CLOCK_50, Run, DOUT, ADDR, W);

endmodule
