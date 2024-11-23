module csr(
    input clk,
    input resetn,
    input [11:0] csr_addr,
    input [31:0] data_in,
    input write_en,
    input done,
    input scratch,
    output [31:0] mstatus,
    output [31:0] mie,
    output [31:0] mip,
    input [31:0] mcause,
    input [31:0] mbadaddr,
    input [31:0] mepc,
    output reg [31:0] csr_readbus
);
    parameter XLEN = 32;

    reg [63:0] mtime;
    reg [63:0] mtimecmp;
    reg [47:0][31:0] csreg;

    wire [23:0] group;
    assign group = csr_addr[31:8];
    wire [7:0] select;
    assign select = csr_addr[7:0];

    assign mstatus = csreg['h5];
    assign mie = csreg['h8];
    assign mip = csreg['hE];
    //assign mcause = csreg['hC];
    assign csreg['hC] = mcause;
    //assign mbadaddr = csreg['hD];
    assign csreg['hD] = mbadaddr;
    assign csreg['hB] = mepc;
    //TODO timer implementation and wiring


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
                        8'h4: csreg['hE] <= data_in;
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
            default:;
            endcase
        end
        //TODO check privilege mode to ensure proper write


    initial begin
      $dumpfile("dump.vcd");
      $dumpvars(1, csr);
    end
endmodule