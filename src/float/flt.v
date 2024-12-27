module flt(
    input clk,
    input resetn,
    input [31:0] rs1,
    input [31:0] rs2,
    output reg [31:0] out
);

wire [22:0] mantissa1;
wire sign1;
wire [7:0] exponent1;
wire [22:0] mantissa2;
wire sign2;
wire [7:0] exponent2;
wire NaN1, NaN2;

assign NaN1 = (exponent1 != 8'b11111111) & (mantissa1 > 0);
assign NaN2 = (exponent2 != 8'b11111111) & (mantissa2 > 0);

assign sign1 = rs1[31];
assign mantissa1 = rs1[22:0];
assign exponent1 = rs1[30:23];
assign sign2 = rs2[31];
assign mantissa2 = rs2[22:0];
assign exponent2 = rs2[30:23];


wire [31:0] temp1, temp2;
assign temp1 = {~rs1[31], rs1[30:0]};
assign temp2 = {~rs2[31], rs2[30:0]};

always@(*) begin
    if (NaN1 | NaN2) out = 32'b0;
    else if (temp1 < temp2) begin
        out = 1;
    end
    else begin
        out = 32'b0;
    end
end

// Dump waves
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, flt);
end
endmodule
