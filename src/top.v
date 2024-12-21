`timescale 10ns/10ns

module top(/*AUTOARG*/
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
	wire inst_mem_cs, SW_cs, seg7_cs, LED_reg_cs, x_cs, y_cs, col_cs, vga_write_cs;

	wire [8:0] colour;
	wire [15:0] x;
	wire [15:0] y;
	wire writeEn;

	assign word_addr = realaddr >> 2;

	assign inst_mem_cs = (realaddr[15:12] == 4'h0);
    assign LED_reg_cs = (realaddr[15:12] == 4'h1);
    assign seg7_cs = (realaddr[15:12] == 4'h2);
    assign SW_cs = (realaddr[15:12] == 4'h3);
    assign vga_cs = (realaddr[15:12] == 4'h4);
	//assign kbd_data_cs = (word_addr == 16'h5000);  // PS2 Keyboard data register port
    //assign kbd_makeBreak_cs = (word_addr == 16'h5001);  // PS2 Keyboard makeBreak register port
    //assign kbd_edgeCapture_cs = (word_addr == 16'h5002);  // PS2 Keyboard edgeCapture register port


    assign x_cs = (realaddr[3:0] == 4'h0);
    assign y_cs = (realaddr[3:0] == 4'h4);
    assign col_cs = (realaddr[3:0] == 4'h8);
    assign vga_write_cs = (realaddr[3:0] == 4'hC);
		
	assign LEDR = temp2[9:0];

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
    

	regn #(.n(9)) U8 (dout[8:0], resetn, vga_cs & W & col_cs, clk, colour);
    regn #(.n(16)) U9 (dout[15:0], resetn, vga_cs & W & x_cs, clk, x);
    regn #(.n(16)) U10 (dout[15:0], resetn, vga_cs & W & y_cs, clk, y);
    regn #(.n(1)) U11 (dout[0], resetn, vga_cs & W & vga_write_cs, clk, writeEn);
	

	// Dump waves
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(1, top);
    end
endmodule