module fcvt_s_w(
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
reg [5:0] a;
reg [5:0] k;
reg [7:0] exp;

assign s_out = rs1[31];
assign a = log(sig);
assign mantissa = sig << k;
assign exp = 127 + a;
assign k = 23 - a;

always@(*) begin
    sig = s_out ? ~rs1 + 1 : rs1;
    if (rs1[30:0]==0) begin
        out = {s_out ,31'b0000000000000000000000000000000};
    end
    else begin
        out = {s_out, exp, mantissa};
    end
end

// Dump waves
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, fcvt_s_w);
end
endmodule