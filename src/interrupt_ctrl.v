module interrupt_ctrl(
    input clk,
    input [31:0] pc,
    input [31:0] mstatus,
    input [31:0] mie,
    input [31:0] mip,
    input [31:0] mcause,
    output [31:0] mbadaddr,
    output [31:0] mepc
    //input [31:0] mtvec, should be handled in the processor itself
    //mepc also handled 1 level above

);
    always@(posedge clk)
        //instruction address misaligned
        if (pc[1:0] != 2'b00) begin
            mbadaddr <= pc;
            mepc <= pc;
        end

        //Illegal instruction
        //else if () begin
        //end

        //Load address misaligned


        //Store address misaligned
   
    // Dump waves
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(1, interrupt_ctrl);
    end

endmodule