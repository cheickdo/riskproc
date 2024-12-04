module fcvt(
    input clk,
    input resetn,
    input [31:0] rs1,
    input [31:0] rs2,
    output reg [31:0] out
);

wire s_out;
reg [31:0] sig;
reg [31:0] test;
reg [31:0] i;

assign s_out = rs1[31];

always@(*) begin
    sig = s_out ? ~rs1 + 1 : rs1;

    if (rs1[30:0]==0) begin
        out = {s_out ,31'b0000000000000000000000000000000};
    end
    else begin
        for (i=32;i<1;i=i-1) begin
            if (rs1[i] != 0) begin
                test = i;
            end
        end
    end
end

// Dump waves
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, fcvt);
end
endmodule