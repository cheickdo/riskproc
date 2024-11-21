module csr(
    input clk,
    input resetn,
    input [11:0] csr_addr,
    input [31:0] data_in,
    input write_en,
    input done,
    input scratch,
    output reg [31:0] csr_readbus
);
    parameter XLEN = 32;

    reg [63:0] mtime;
    reg [63:0] mtimecmp; //not a csr, implement own memory mapping
    //reg [4095:0][31:0] csreg; //too many registers, ends up breaking, implement my own register map set
    reg [47:0][31:0] csreg;

    wire [23:0] type = csr_addr[31:8];
    wire [7:0] select = csr_addr[7:0];

    //TODO timer implementation and wiring

    //TODO interrupt and exception handler

    //decoder for reading
    always@(*) begin
        csr_readbus = csreg[csr_addr]; //only should be allowed given privilege mode of process TODO
    end

    //assign csreg['hF01] = mtime;
    //assign csreg['hF81] = mtimeh;

    //read only registers
    assign csreg[0]  = 32'b10000000000100000000000100000000;//misa register
    assign csreg[1]  = 32'b00000000000000000000000000000000;//mvendorid, non-commercial device
    assign csreg[2]  = 32'b00000000000000000000000000000000;//marchid
    assign csreg[3]  = 32'b00000000000000000000000000000000;//mimpid
    assign csreg[4]  = 32'b00000000000000000000000000000000;//mhartid

    always@(posedge clk)

        if (resetn)  {csreg['hF80],csreg['hF00]} <= 0; //cycle counter
        else {csreg['hF80],csreg['hF00]} <= {csreg['hF80],csreg['hF00]} + 1; //cycle counter

        if (write_en) begin //write enabled
            //if (scratch == 1'b1) csreg['h340] <= data_in;
            case(type)
            24'h30: begin
                csreg[select+'h5] <= data_in;
            end
            24'h34: begin
                csreg[select+'hA] <= data_in;
            end
            24'h31: begin
                csreg[select+'h15] <= data_in;
            end
            24'h70: begin 
                csreg[select+'h18] <= data_in;
            end
            24'h78: begin 
                csreg[select+'h21] <= data_in;
            end
            default:;
            endcase

        end
        else begin //read
            case(type)
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
            default:;
            endcase
        end
        //TODO check privilege mode to ensure proper write


    initial begin
      $dumpfile("dump.vcd");
      $dumpvars(1, csr);
    end
endmodule