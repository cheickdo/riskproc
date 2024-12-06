module fcvt_w_s(
    input clk,
    input resetn,
    input [31:0] rs1,
    input [31:0] rs2,
    output reg [31:0] out
);

wire s_out;
reg [31:0] sig;

reg [22:0] mantissa;
reg [31:0] i;
reg [31:0] pre_sig;


assign s_out = rs1[31];
assign i = 127 + 23 - rs1[30:23];
assign pre_sig = {1'b1,sig[22:0]} >> i;



always@(*) begin
    sig = s_out ? ~pre_sig + 1 : pre_sig;
    if (rs1[31:0]==0) begin
        out = {s_out ,31'b0000000000000000000000000000000};
    end
    else begin
        out = {sig};
    end
end

// Dump waves
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, fcvt_w_s);
end
endmodule
