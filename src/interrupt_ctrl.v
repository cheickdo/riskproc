module interrupt_ctrl(
    input [31:0] mstatus,
    input [31:0] mie,
    input [31:0] mip,
    input [31:0] mcause
    //input [31:0] mtvec, should be handled in the processor itself
    //mepc also handled 1 level above

);
endmodule