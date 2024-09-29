
module top(/*AUTOARG*/);
    /*AUTOWIRE*/
    // Beginning of automatic wires (for undeclared instantiated-module outputs)
    wire		W;			// From core0 of proc.v
    wire [31:0]		din;			// From mem0 of memory.v
    wire [31:0]		dout;			// From core0 of proc.v
    wire [31:0]		realaddr;		// From core0 of proc.v
    // End of automatics

    proc core0 (/*AUTOINST*/
		// Outputs
		.dout			(dout[31:0]),
		.realaddr		(realaddr[31:0]),
		.W			(W),
		// Inputs
		.din			(din[31:0]),
		.resetn			(resetn),
		.clk			(clk),
		.run			(run));

    memory mem0(/*AUTOINST*/
		// Outputs
		.din			(din[31:0]),
		// Inputs
		.clk			(clk),
		.W			(W),
		.realaddr		(realaddr[4:0]),
		.dout			(dout[31:0]));
    
endmodule
