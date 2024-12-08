/*
Single Precision IEEE 754 floating point adder
    chk
*/
module fpadd(
    input clk,
    input resetn,
    input [31:0] rs1,
    input [31:0] rs2,
    output [31:0] out
);
    wire [7:0] e1 ,e2;
    wire s1 ,s2;
    wire [22:0] m1, m2; 
    reg [7:0] e_out;
    reg [22:0] m_out;
    reg done;

    reg s1_pipe, s12_pipe,s13_pipe,s14_pipe,s2_pipe,s22_pipe,s23_pipe,s24_pipe;
    reg sign_out;
    
    reg [7:0] e_diff, low_e, high_e, e1_pipe,e12_pipe,e13_pipe,e14_pipe,e2_pipe,e22_pipe,e23_pipe,e24_pipe;
    reg [22:0] low_m, high_m;
    reg [7:0] low_e_pipe, low_e2_pipe, low_e3_pipe, high_e_pipe, high_e2_pipe, high_e3_pipe, high_e4_pipe;
    reg [23:0] low_m_shift, high_m_shift;
    reg [23:0] low_m_pipe, low_m2, high_m2, low_m2_pipe,high_m_pipe,high_m2_pipe, m1_pipe, m12_pipe, m13_pipe, m14_pipe, m2_pipe, m22_pipe, m23_pipe, m24_pipe;

	reg [24:0] sum_m_pipe, sum_m, sum_m2;
	reg [3:0] renorm_shift, renorm_shift_pipe;
   reg signed [6:0] renorm_exp, renorm_exp_pipe;

    assign e1 = rs1[30:23];
    assign e2 = rs2[30:23];
    assign s1 = rs1[31];
    assign s2 = rs2[31];
    assign m1 = rs1[22:0];
    assign m2 = rs2[22:0];

    assign out = {sign_out, e_out, m_out};

    //combinational stages
    always@(*) begin
        //stage1
        //check exponent and shift mantissa
        if (e1 > e2) begin
            e_diff = e1-e2;
            low_m = m2;
            high_m = m1;
            low_e = e2;
            high_e = e1;
        end
        else begin
            e_diff = e2-e1;
            low_m = m1;
            high_m = m2;
            low_e = e1;
            high_e = e2;
        end
             
        if (low_e != 0) begin
           low_m_shift = {1'b1, low_m} >> e_diff;
           //low_m_shift = low_m_shift >> e_diff;
        end
        else begin
            low_m_shift = {1'b0, low_m};
        end

        if (high_e != 0) begin
            high_m_shift = {1'b1, high_m};
        end
        else begin
            high_m_shift = {1'b0, high_m};
        end

        //stage2
        //set new lowest mantissa
        if (low_m_pipe > high_m_pipe) begin
            low_m2 = high_m_pipe;
            high_m2 = low_m_pipe;
        end
        else begin
            low_m2 = low_m_pipe;
            high_m2 = high_m_pipe;
        end

        //stage3
        if (s22_pipe == s12_pipe)
            sum_m = low_m2_pipe + high_m2_pipe;
        else  
            sum_m =  high_m2_pipe - low_m2_pipe;

        if (sum_m[24]) begin
            renorm_shift = 4'd0;
            renorm_exp = 4'd1;
        end
        else if (sum_m[23]) begin
            renorm_shift = 4'd1;
            renorm_exp = 4'd0;
        end
        else if (sum_m[22])begin
            renorm_shift = 4'd2;
            renorm_exp = -1;		
        end
        else if (sum_m[21])begin
            renorm_shift = 4'd3; 
            renorm_exp = -2;
        end 
        else if (sum_m[20])begin
            renorm_shift = 4'd4; 
            renorm_exp = -3;		
        end  
        else if (sum_m[19])begin
            renorm_shift = 4'd5; 
            renorm_exp = -4;		
        end     
            else begin
            renorm_exp = 0;
        end	

        //stage4
        e_out = high_e3_pipe + renorm_exp_pipe;

        if (renorm_shift_pipe != 0) begin	
            m_out = sum_m_pipe << (renorm_shift_pipe -1);
        end
        else begin
            m_out = sum_m_pipe >> 1;
        end
        //m_out = sum_m2[23:1];  	

        //if (s14_pipe == s24_pipe) begin
        //    sign_out = s14_pipe;
        //end 
        if (e13_pipe > e23_pipe) begin
            sign_out = s13_pipe;	
        end else if (e13_pipe < e23_pipe) begin
            sign_out = s23_pipe;
        end
        else begin
            if (m13_pipe > m23_pipe) begin
                sign_out = s13_pipe;		
            end else begin
                sign_out = s23_pipe;
            end
        end	

    end


    //pipe
    always@(posedge clk)
        if (!resetn) begin
        s1_pipe <= 0;
        s12_pipe <= 0;
        s13_pipe <= 0;
        s14_pipe <= 0;
        s2_pipe <= 0;
        s22_pipe <= 0;
        s23_pipe <= 0;
        s24_pipe <= 0;
        e1_pipe <= 0;
        e12_pipe <= 0;
        e13_pipe <= 0;
        e14_pipe <= 0;
        e2_pipe <= 0;
        e22_pipe <= 0;
        e23_pipe <= 0;
        e24_pipe <= 0;        
        low_m_pipe <= 0;
        low_m2_pipe <= 0;
        high_m_pipe <= 0;
        high_m2_pipe <= 0;
        low_e_pipe <= 0;
        //low_e2_pipe <= 0;
        //low_e3_pipe <= 0;
        high_e_pipe <= 0;
        high_e2_pipe <= 0;
        high_e3_pipe <= 0;
        high_e4_pipe <= 0;
        m1_pipe <= 0;
        m12_pipe <= 0;
        m13_pipe <= 0;
        m14_pipe <= 0;
        m2_pipe <= 0;
        m22_pipe <= 0;
        m23_pipe <= 0;
        m24_pipe <= 0;
		sum_m_pipe <= 0;
		renorm_shift_pipe <= 0;
        renorm_exp_pipe <= 0;
        done <= 0;
        end
        else begin
        s1_pipe <= s1;
        s12_pipe <= s1_pipe;
        s13_pipe <= s12_pipe;
        s14_pipe <= s13_pipe;
        s2_pipe <= s2;
        s22_pipe <= s2_pipe;
        s23_pipe <= s22_pipe;
        s24_pipe <= s23_pipe;
        e1_pipe <= e1;
        e12_pipe <= e1_pipe;
        e13_pipe <= e12_pipe;
        e14_pipe <= e13_pipe;
        e2_pipe <= e2;
        e22_pipe <= e2_pipe;
        e23_pipe <= e22_pipe;
        e24_pipe <= e23_pipe;        
        low_m_pipe <= low_m_shift;
        low_m2_pipe <= low_m2;
        high_m_pipe <= high_m_shift;
        high_m2_pipe <= high_m2;
        //low_e_pipe <= 0;
        //low_e2_pipe <= 0;
        //low_e3_pipe <= 0;
        high_e_pipe <= high_e;
        high_e2_pipe <= high_e_pipe;
        high_e3_pipe <= high_e2_pipe;
        high_e4_pipe <= high_e3_pipe;
        m1_pipe <= m1;
        m12_pipe <= m1_pipe;
        m13_pipe <= m12_pipe;
        m14_pipe <= m13_pipe;
        m2_pipe <= m2;
        m22_pipe <= m2_pipe;
        m23_pipe <= m22_pipe;
        m24_pipe <= m23_pipe;
		sum_m_pipe <= sum_m;
		renorm_shift_pipe <= renorm_shift;
        renorm_exp_pipe <= renorm_exp;        
        end


  // Dump waves
  initial begin
      $dumpfile("dump.vcd");
      $dumpvars(1, fpadd);
  end
endmodule