module fmul(
    input clk,
    input resetn,
    input [31:0] rs1,
    input [31:0] rs2,
    output [31:0] out
);

wire s1, s2;
wire [7:0] e1, e2;
wire [22:0] m1, m2;

reg s_out;

reg tst;

reg [23:0] m11, m21, m12, m22, m13, m23,m11_pipe, m21_pipe,m12_pipe, m22_pipe;
reg [8:0] sum_e, sum3_e, sum_e_pipe, sum2_e_pipe,norm_e_pipe;

//pipes
reg [7:0] e11_pipe, e21_pipe, e12_pipe, e22_pipe, e13_pipe, e23_pipe, e_out; 
reg [22:0]  m_out;

reg [47:0] prod_m, prod2_m, norm_m_pipe, prod_m_pipe;

assign s1 = rs1[31];
assign s2 = rs2[31]; 
assign e1 = rs1[30:23];
assign e2 = rs2[30:23];
assign m1 = rs1[22:0];
assign m2 = rs2[22:0];

assign out = {s_out, e_out,m_out};

//combinational stages
always@(*) begin
    //stage 1
    //add signs, determine mantissa
    s_out = s1 ^ s2;

    if (e1 != 0) begin
        m11 = {1'b1, m1};
    end
    else begin
        m11 = {1'b0, m1};
    end

    if (e2 != 0) begin
        m21 = {1'b1, m2};
    end
    else begin
        m21 = {1'b0, m2};
    end
    //stage2
    //add exponents
    sum_e = e11_pipe + e21_pipe -127;
    //stage3
    //multiply fractional part
    prod_m = m12_pipe * m22_pipe;

    //stage4
    //renormalization
    if (prod_m_pipe[47] == 1) begin
        norm_e_pipe = sum2_e_pipe + 1;
        norm_m_pipe = prod_m_pipe >> 1;
    end 
    else if ((prod_m_pipe[46] != 1) & (sum2_e_pipe != 0)) begin
        if (prod_m_pipe[46:41] == 6'b000001) begin
			norm_e_pipe = sum2_e_pipe - 5;
			norm_m_pipe = prod_m_pipe << 5;
		end else if (prod_m_pipe[46:42] == 5'b00001) begin
			norm_e_pipe = sum2_e_pipe - 4;
			norm_m_pipe = prod_m_pipe << 4;
		end else if (prod_m_pipe[46:43] == 4'b0001) begin
			norm_e_pipe = sum2_e_pipe - 3;
			norm_m_pipe = prod_m_pipe << 3;
		end else if (prod_m_pipe[46:44] == 3'b001) begin
			norm_e_pipe = sum2_e_pipe - 2;
			norm_m_pipe = prod_m_pipe << 2;
		end else if (prod_m_pipe[46:45] == 2'b01) begin
			norm_e_pipe = sum2_e_pipe - 1;
			norm_m_pipe = prod_m_pipe << 1;
        end else begin
            norm_e_pipe = sum2_e_pipe;
            norm_m_pipe = prod_m_pipe;
        end
    end 
    else begin
            norm_e_pipe = sum2_e_pipe;
            norm_m_pipe = prod_m_pipe;
    end        
    m_out = norm_m_pipe[46:23];
    e_out = norm_e_pipe;
end


//pipe
always@(posedge clk)
    if (!resetn) begin
        e11_pipe <= 0;
        e21_pipe <= 0;
        m11_pipe <= 0;
        m21_pipe <= 0;
        m12_pipe <= 0;
        m22_pipe <= 0;
        sum_e_pipe <= 0;
        sum2_e_pipe <= 0;
        prod_m_pipe <= 0;
    end
    else begin
        e11_pipe <= e1;
        e21_pipe <= e2;
        m11_pipe <= m11;
        m21_pipe <= m21;
        m12_pipe <= m11_pipe;
        m22_pipe <= m21_pipe;
        prod_m_pipe <= prod_m;
        sum_e_pipe <= sum_e;
        sum2_e_pipe <= sum_e_pipe;
    end

// Dump waves
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, top);
end
endmodule
