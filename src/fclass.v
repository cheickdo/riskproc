module fclass(
    input clk,
    input resetn,
    input [31:0] rs1,
    input [31:0] rs2,
    output reg [31:0] out
);

wire [22:0] mantissa;
wire sign;
wire [7:0] exponent;

assign sign = rs1[31];
assign mantissa = rs1[22:0];
assign exponent = rs1[30:23];

//0 -> rs1 is -inf
//1 rs1 is negative normal
//2 rs1 is negative subnormal number
//3 rs1 is negative 0
//4 rs1 is positive 0
//5 rs1 is positive subnormal number
//6 rs1 is positive normal number
//7 rs1 is +inf
//8 rs1 is signaling NaN
//9 rs1 is quiet NaN

//subnormal -> value of 0 before binary
//normal -> value of 1 before binary

always@(*) begin
    if ((exponent == 8'b11111111) & (sign == 1'b1)) begin
        out = 0;
    end
    else if ((exponent != 8'b00000000) & (sign == 1'b1)) begin
        out = 1;
    end
    else if ((exponent == 8'b00000000) & (sign == 1'b1)) begin
        out = 2;
    end
    else if ((exponent == 8'b0) & (sign == 1'b1) & (mantissa == 22'b0)) begin
        out = 3;
    end
    else if ((exponent == 8'b0) & (sign == 1'b0) & (mantissa == 22'b0)) begin
        out = 4;
    end
    else if ((exponent == 8'b0) & (sign == 1'b0)) begin
        out = 5;
    end
    else if ((exponent != 8'b0) & (sign == 1'b0)) begin
        out = 6;
    end
    else if ((exponent == 8'b11111111) & (sign == 1'b0)) begin
        out = 7;
    end
    else if ((exponent != 8'b11111111) & (mantissa > 0) & (mantissa[22] == 1'b0)) begin
        out = 8;
    end
    else if ((exponent != 8'b11111111) & (mantissa > 0) & (mantissa[22] == 1'b1)) begin
        out = 9;
    end
end

// Dump waves
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, fclass);
end
endmodule