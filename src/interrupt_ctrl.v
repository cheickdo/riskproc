module interrupt_ctrl(
    input clk,
    input [31:0] pc,
    input [31:0] mstatus,
    input [31:0] mie,
    input [31:0] mip,
    output reg [31:0] mcause,
    input done,
    output reg [31:0] mbadaddr,
    output reg [31:0] mepc,
    output reg trap
    //input [31:0] mtvec, should be handled in the processor itself
    //mepc also handled 1 level above

);
    always@(posedge clk)
        if ((done == 1) & (mepc != 32'h0)) begin
            trap <= 1;
        end
        else trap <= 0;

    always@(posedge clk)

        //instruction address misaligned
        if (pc[1:0] != 2'b00) begin
            mbadaddr <= pc;
            mepc <= pc;
            mcause <= 0;
        end
        else begin
            mbadaddr <= 0;
            mepc <= 0;
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