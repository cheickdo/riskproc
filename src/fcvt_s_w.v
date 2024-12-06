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
assign a = log(rs1);
assign mantissa = rs1 << k;
assign exp = 127 + a - 1;
assign k = 24 - a;

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

//big combinational block
function integer log;
    input [size-1:0] in;
    integer i;

    parameter size = 32;

    begin
    log = 0;
    for(i=0; 2**i < in; i = i+1)
    log = i+1;
    end
endfunction