`timescale 10ns/10ns

module top(/*AUTOARG*/
	//input [9:0] SW,
	//input [3:0] KEY,
	//input CLOCK_50,
	//output [9:0] LEDR,
	input clk,
	input run,
	input resetn
);

    /*AUTOWIRE*/
    // Beginning of automatic wires (for undeclared instantiated-module outputs)
    wire		W;			// From core0 of proc.v
    wire [31:0]		din;			// From mem0 of memory.v
    wire [31:0]		dout;			// From core0 of proc.v
    wire [31:0]		realaddr;		// From core0 of proc.v
	wire [31:0] waste;
	wire [31:0] ina;
	wire [21:0] temp;
	reg [31:0] temp2;

	wire [31:0] word_addr;

	assign word_addr = realaddr >> 2;
    // End of automatics
	 
	 /*
	 RAM	RAM_inst (
	.address ( word_addr[15:0] ),
	.clock ( CLOCK_50 ),
	.data ( dout ),
	.wren ( W),
	.q ( din )
	);*/
	
	always@(*)
		if ((W == 1) & (word_addr == 16'b0000000000001111)) temp2 = dout;
		
	assign LEDR = temp2[9:0];
	
	

	//part1 u0(.MuxSelect(SW[9:7]), .Input(SW[6:0]), .Out(LEDR[0]));

	/*
    proc core0 ( //testing core
		// Outputs
		.dout			(dout[31:0]),
		.realaddr		(word_addr[31:0]),
		.W			(W),
		// Inputs
		.din			(din[31:0]),
		.resetn			(SW[1]),
		.clk			(KEY[0]),
		.run			(SW[0]));
	*/

    proc core0 (//simulation core
		// Outputs
		.dout			(dout[31:0]),
		.realaddr		(realaddr[31:0]),
		.W			(W),
		// Inputs
		.din			(din[31:0]),
		.resetn			(resetn),
		.clk			(clk),
		.run			(run));


    memory mem0(
		 //Outputs
		.din			(din[31:0]),
		 //Inputs
		.clk			(clk),
		.W			(W),
		.realaddr		(word_addr[15:0]),
		.dout			(dout[31:0]));
    
endmodule

module part1(MuxSelect, Input, Out);
	input [2:0] MuxSelect;
	input [6:0] Input;
	output reg Out;

	always@(*)
	begin
		case (MuxSelect[2:0])
		3'b000: Out = Input[0];
		3'b001: Out = Input[1];
		3'b010: Out = Input[2];
		3'b011: Out = Input[3];
		3'b100: Out = Input[4];
		3'b101: Out = Input[5];
		3'b110: Out = Input[6];
		default: Out = 0;
		endcase
	end

endmodule
