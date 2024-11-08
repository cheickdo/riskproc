module csr(
    input clk,
    input [11:0] csr_addr,
    input [31:0] data_in,
    output [31:0] csr_readbus
);
    reg [11:0] csreg [31:0];

    always@(*)
        //Machine information registers, READONLY
        csreg[0xF10]  = 32'b10000000000100000000000100000000;//misa register
        csreg[0xF11]  = 32'b00000000000000000000000000000000;//mvendorid, non-commercial device
        csreg[0xF12]  = 32'b00000000000000000000000000000000;//marchid
        csreg[0xF13]  = 32'b00000000000000000000000000000000;//mimpid
        csreg[0xF14]  = 32'b00000000000000000000000000000000;//mhartid


endmodule