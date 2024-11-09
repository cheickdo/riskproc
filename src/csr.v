module csr(
    input clk,
    input resetn,
    input [11:0] csr_addr,
    input [31:0] data_in,
    input write_en,
    output reg [31:0] csr_readbus
);
    reg [31:0] csreg [11:0];
    parameter XLEN = 32;

    initial begin
      $dumpfile("dump.vcd");
      $dumpvars(2, csr);
    end

    //decoder for reading
    always@(*) begin
        csr_readbus = csreg[csr_addr]; //only should be allowed given privilege mode of process TODO
    end

    always@(posedge clk)
        if (!resetn) begin //initializations of csr registers
            //Machine information registers, machine READONLY
            csreg['hF10]  <= 32'b10000000000100000000000100000000;//misa register
            csreg['hF11]  <= 32'b00000000000000000000000000000000;//mvendorid, non-commercial device
            csreg['hF12]  <= 32'b00000000000000000000000000000000;//marchid
            csreg['hF13]  <= 32'b00000000000000000000000000000000;//mimpid
            csreg['hF14]  <= 32'b00000000000000000000000000000000;//mhartid

            //TODO
            csreg['h300]  <= 32'b00000000000000000000000000000000;//mstatus
            csreg['h302]  <= 32'b00000000000000000000000000000000;//medeleg
            csreg['h303]  <= 32'b00000000000000000000000000000000;//mideleg
            csreg['h304]  <= 32'b00000000000000000000000000000000;//mie
            csreg['h305]  <= 32'b00000000000000000000000000000000;//mtvec

            csreg['h340]  <= 32'b00000000000000000000000000000000;//mscratch
            csreg['h341]  <= 32'b00000000000000000000000000000000;//mepc
            csreg['h342]  <= 32'b00000000000000000000000000000000;//mcause
            csreg['h343]  <= 32'b00000000000000000000000000000000;//mbadaddr
            csreg['h344]  <= 32'b00000000000000000000000000000000;//mip

            csreg['h380]  <= 32'b00000000000000000000000000000000;//mbase
            csreg['h381]  <= 32'b00000000000000000000000000000000;//mbound
            csreg['h382]  <= 32'b00000000000000000000000000000000;//mibase
            csreg['h383]  <= 32'b00000000000000000000000000000000;//mibound
            csreg['h384]  <= 32'b00000000000000000000000000000000;//mdbase
            csreg['h385]  <= 32'b00000000000000000000000000000000;//mdbound

            csreg['hF00]  <= 32'b00000000000000000000000000000000;//mcycle
            csreg['hF01]  <= 32'b00000000000000000000000000000000;//mtime
            csreg['hF02]  <= 32'b00000000000000000000000000000000;//minstret
            csreg['hF80]  <= 32'b00000000000000000000000000000000;//mcycleh
            csreg['hF81]  <= 32'b00000000000000000000000000000000;//mtimeh
            csreg['hF82]  <= 32'b00000000000000000000000000000000;//minsteth

            csreg['h310]  <= 32'b00000000000000000000000000000000;//User-mode counter enable
            csreg['h311]  <= 32'b00000000000000000000000000000000;//Supervisor-mode counter enable
            csreg['h312]  <= 32'b00000000000000000000000000000000;//Hypervisor-mode counter enable

            csreg['h700]  <= 32'b00000000000000000000000000000000;//cycle counter delta
            csreg['h701]  <= 32'b00000000000000000000000000000000;//time counter delta
            csreg['h702]  <= 32'b00000000000000000000000000000000;//instret counter delta

            csreg['h704]  <= 32'b00000000000000000000000000000000;//scycle counter delta
            csreg['h705]  <= 32'b00000000000000000000000000000000;//stime counter delta
            csreg['h706]  <= 32'b00000000000000000000000000000000;//substret counter delta

            csreg['h708]  <= 32'b00000000000000000000000000000000;//hcycle counter delta
            csreg['h709]  <= 32'b00000000000000000000000000000000;//htime counter delta
            csreg['h70A]  <= 32'b00000000000000000000000000000000;//hinstret counter delta

            csreg['h780]  <= 32'b00000000000000000000000000000000;//upper 32bits of cycle counter delta
            csreg['h781]  <= 32'b00000000000000000000000000000000;//upper 32bits of time counter delta
            csreg['h782]  <= 32'b00000000000000000000000000000000;//upper 32bits of instret counter delta

            csreg['h784]  <= 32'b00000000000000000000000000000000;//upper 32bits of sycle counter delta
            csreg['h785]  <= 32'b00000000000000000000000000000000;//upper 32bits of stime counter delta
            csreg['h786]  <= 32'b00000000000000000000000000000000;//upper 32bits of substret counter delta

            csreg['h788]  <= 32'b00000000000000000000000000000000;//upper 32bits of hyclce counter delta
            csreg['h789]  <= 32'b00000000000000000000000000000000;//upper 32bits of htime delta
            csreg['h78A]  <= 32'b00000000000000000000000000000000;//upper 32bits of hinstret delta

        end
        else if (write_en)
            case(csr_addr)
                'h300: csreg['300] <= data_in; //mstatus
                'h305: csreg['h305] <= data_in & 'hFFFC;// mvtec

                default: ;//raise some exception, illegal write
            endcase
            //csreg['hF15] <= data_in; //check privilege mode to ensure proper write
endmodule