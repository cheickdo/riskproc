`timescale 10ns/10ns

module top_fpga(/*AUTOARG*/
	input [9:0] SW,
	input [3:0] KEY,
	input CLOCK_50,
	output [9:0] LEDR,
	output VGA_CLK,
	output VGA_HS, 
	output VGA_VS, 
	output VGA_BLANK_N, 
	output VGA_SYNC_N, 
	output [7:0] VGA_R, 
	output [7:0] VGA_G, 
	output [7:0] VGA_B
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

	wire [8:0] colour;
	wire [15:0] x;
	wire [15:0] y;
	wire writeEn;

	//TODO use inst_mem_cs
	wire inst_mem_cs, SW_cs, seg7_cs, LED_reg_cs, x_cs, y_cs, col_cs, vga_write_cs;
	wire [15:0] DOUT;
	wire [31:0] word_addr;
	wire [31:0] pctest;

	wire vga_cs;
	
	//TODO to modify
	
	assign inst_mem_cs = (realaddr[15:12] == 4'h0);
    assign LED_reg_cs = (realaddr[15:12] == 4'h1);
    assign seg7_cs = (realaddr[15:12] == 4'h2);
    assign SW_cs = (realaddr[15:12] == 4'h3);
    assign vga_cs = (realaddr[15:12] == 4'h4);
	//assign kbd_data_cs = (realaddr == 16'h5000);  // PS2 Keyboard data register port
    //assign kbd_makeBreak_cs = (realaddr == 16'h5001);  // PS2 Keyboard makeBreak register port
    //assign kbd_edgeCapture_cs = (realaddr == 16'h5002);  // PS2 Keyboard edgeCapture register port


    assign x_cs = (realaddr[3:0] == 4'h0);
    assign y_cs = (realaddr[3:0] == 4'h4);
    assign col_cs = (realaddr[3:0] == 4'h8);
    assign vga_write_cs = (realaddr[3:0] == 4'hC);


	assign word_addr = realaddr >> 2;
    // End of automatics
	 

	 RAM	RAM_inst (
	.address ( word_addr[15:0] ),
	.clock ( CLOCK_50 ),
	.data ( dout ),
	.wren ( W),
	.q ( din )
	);
	
	//part1 u0(.MuxSelect(SW[9:7]), .Input(SW[6:0]), .Out(LEDR[0]));

	
    proc core0 ( //testing core
		// Outputs
		.dout			(dout[31:0]),
		.realaddr		(realaddr[31:0]),
		.W			(W),
		// Inputs
		.din			(din[31:0]),
		.resetn			(KEY[0]),
		.clk			(CLOCK_50),
		.run			(SW[0]));
		
		
	
	//vga adapter module
    vga_adapter VGA(
			.resetn(KEY[0]),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "320x240";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 3;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
		

	regn #(.n(9)) U8 (dout[8:0], KEY[0], vga_cs & W & col_cs, CLOCK_50, colour);
    regn #(.n(16)) U9 (dout[15:0], KEY[0], vga_cs & W & x_cs, CLOCK_50, x);
    regn #(.n(16)) U10 (dout[15:0], KEY[0], vga_cs & W & y_cs, CLOCK_50, y);
    regn #(.n(1)) U11 (dout[0], KEY[0], vga_cs & W & vga_write_cs, CLOCK_50, writeEn);
    
	 assign LEDR[9:0] = realaddr[9:0];
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
