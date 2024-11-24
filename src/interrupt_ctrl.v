module interrupt_ctrl(
    input clk,
    input load,
    input [31:0] addr,
    input [31:0] pc,
    input [31:0] mstatus,
    input [31:0] mie,
    input [31:0] mip,
    input [7:0] opcode,
    input W,
    input [31:0] G,
    input time_compare,
    input [31:0] Sum,
    input done,

    output reg [31:0] mcause,
    output reg [31:0] mbadaddr,
    output reg [31:0] mepc,
    output reg trap
    //input [31:0] mtvec, should be handled in the processor itself
    //mepc also handled 1 level above

);

    parameter S_type = 7'b0100011,I_type_1=7'b0000011;

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
        // load addresss misaligned
        else if ((load == 1) & (addr[1:0] != 2'b00) & (W == 0)) begin
            mepc <= pc;
            mbadaddr <= pc;
            mcause <= 4;
        end
        //store address misaligned
        else if  (/*(W == 1) &*/ (Sum[1:0] != 2'b00) & (opcode == S_type)) begin
            mepc <= pc;
            mbadaddr <= pc;
            mcause <= 5;
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