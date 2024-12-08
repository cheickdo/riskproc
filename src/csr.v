module csr(
    input clk,
    input resetn,
    input [31:0] csr_addr,
    input [31:0] data_in,
    input write_en,
    input done,
    input scratch,
    output reg [31:0] mstatus,
    output reg [31:0] mie,
    input [31:0] mip,
    input [31:0] mcause,
    input [31:0] mbadaddr,
    input [31:0] mepc,
    output reg [31:0] mtvec,
    output reg time_compare,
    output reg [31:0] fcsr,
    input [4:0] fflags,
    output reg [31:0] csr_readbus
);
 parameter XLEN = 32;

 //reg [63:0] mtime;
 reg [63:0] mtimecmp;
 reg [31:0] csreg[48:0]; //to recheck, change was done for hardware
 wire [31:0] w_cs_addr;
 wire [31:0] mcycle, mcycleh, minstret, minstreth, mtime, mtimeh;

 assign w_cs_addr = csr_addr >> 2;

 wire [23:0] group;
 assign group = w_cs_addr[15:4];
 wire [7:0] select;
 assign select = w_cs_addr[3:0];

always@(*) begin
	fcsr = csreg['h2C];
	mstatus = csreg['h5];
	mie = csreg['h8];
	mtvec = csreg['h9];

	csreg['hE] = mip;
	csreg['hC] = mcause;
	csreg['hD] = mbadaddr;
	csreg['hB] = mepc;
	 
	csreg['hF] = mcycle;
	csreg['h12] = mcycleh;
	csreg['h11] = minstret;
	csreg['h14] = minstreth;
	
	//read only registers
	csreg[0]  = 32'b10000000000100000000000100000000;//misa register
	csreg[1]  = 32'b00000000000000000000000000000000;//mvendorid, non-commercial device
	csreg[2]  = 32'b00000000000000000000000000000000;//marchid
	csreg[3]  = 32'b00000000000000000000000000000000;//mimpid
	csreg[4]  = 32'b00000000000000000000000000000000;//mhartid
end

 //TODO timer implementation and wiring

 //instantiations
 counter #(.XLEN(64)) machine_cycle(
	  .clk(clk),
	  .resetn(resetn),
	  .enable(1'b1),
	  .out({mcycleh,mcycle})
 );

 counter  #(.XLEN(64)) machine_instret(
	  .clk(clk),
	  .resetn(resetn),
	  .enable(done),
	  .out({minstreth,minstret})
 );

 counter  #(.XLEN(64)) timer(
	  .clk(clk),
	  .resetn(resetn),
	  .enable(1'b1),
	  .out({mtimeh,mtime})
 );

 //time compare logic
 always@(*)
	  if (mtimecmp <= {mtime,mtimeh})
			time_compare = 1;
	  else
			time_compare = 0;


 //decoder for reading
 always@(*) begin
	  //csr_readbus = csreg[w_cs_addr]; //only should be allowed given privilege mode of process TODO
 end

 always@(posedge clk)

	  //if (resetn)  {csreg['hF80],csreg['hF00]} <= 0; //cycle counter
	  //else {csreg['hF80],csreg['hF00]} <= {csreg['hF80],csreg['hF00]} + 1; //cycle counter
	  if (write_en) begin //write enabled
			//if (scratch == 1'b1) csreg['h340] <= data_in;
			case(group)
				 24'h30: begin
					  case(select)
							8'h0: csreg[5] <= data_in;
							8'h2: csreg[6] <= data_in;
							8'h3: csreg[7] <= data_in;
							8'h4: csreg[8] <= data_in;
							8'h5: csreg[9] <= data_in;
					  endcase
				 end
				 24'h34: begin
					  case(select)
							8'h0: csreg['hA] <= data_in;
							//8'h1: csreg['hB] <= data_in;
							//8'h2: csreg['hC] <= data_in;
							//8'h3: csreg['hD] <= data_in;
							//8'h4: csreg['hE] <= data_in;
					  endcase
				 end
				 24'h31: begin
					  case(select)
							8'h0: csreg['h15] <= data_in;
							8'h1: csreg['h16] <= data_in;
							8'h2: csreg['h17] <= data_in;
					  endcase
				 end
				 24'h70: begin 
					  case(select)
							8'h0: csreg['h18] <= data_in;
							8'h1: csreg['h19] <= data_in;
							8'h2: csreg['h1A] <= data_in;
							8'h4: csreg['h1B] <= data_in;
							8'h5: csreg['h1C] <= data_in;
							8'h6: csreg['h1D] <= data_in;
							8'h8: csreg['h1E] <= data_in;
							8'h9: csreg['h1F] <= data_in;
							8'hA: csreg['h20] <= data_in;
					  endcase
				 end
				 24'h78: begin 
					  case(select)
							8'h0: csreg['h21] <= data_in;
							8'h1: csreg['h22] <= data_in;
							8'h2: csreg['h23] <= data_in;
							8'h4: csreg['h24] <= data_in;
							8'h5: csreg['h25] <= data_in;
							8'h6: csreg['h26] <= data_in;
							8'h8: csreg['h27] <= data_in;
							8'h9: csreg['h28] <= data_in;
							8'hA: csreg['h29] <= data_in;
					  endcase
				 end
				 24'h80: begin
					  case(select)
							8'h0: mtimecmp[31:0] <= data_in;
							8'h1: mtimecmp[63:32] <= data_in;
					  endcase
				 end
				 24'h90: begin
					  csreg['h2C] <= data_in;
				 end
				 default:;
			endcase

	  end
	  else begin //read
			case(group)
			24'h30: begin
				 csr_readbus <= csreg[select+'h5];
			end
			24'h34: begin
				 csr_readbus <= csreg[select+'hA];
			end
			24'hF0: begin
				 csr_readbus <= csreg[select+'hF];
			end
			24'hF8: begin
				 csr_readbus <= csreg[select + 'h12];
			end
			24'h31: begin
				 csr_readbus <= csreg[select + 'h15];
			end
			24'h70: begin
				 csr_readbus <= csreg[select + 'h18];
			end
			24'h78: begin
				 csr_readbus <= csreg[select + 'h21];
			end
			24'h80: begin
				 if (select == 0)
					  csr_readbus <= mtimecmp[31:0];
				 else if (select == 1)
					  csr_readbus <= mtimecmp[63:32];
			end
			24'h90: begin
				 csr_readbus <= csreg[select + 'h2C];
			end
			default:;
			endcase
	  end
	  //TODO check privilege mode to ensure proper write


 initial begin
	$dumpfile("dump.vcd");
	$dumpvars(1, csr);
 end
endmodule