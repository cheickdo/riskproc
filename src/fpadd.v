/*
Single Precision IEEE 754 floating point adder
    chk
*/

module fpadd(
    input clk,
    input resetn,
    input rs1,
    input rs2,
    output 
);
    wire [7:0] e1 ,e2;
    wire s1 ,s2;
    wire [22:0] m1, m2; 

    reg [7:0] e_diff;
    reg [22:0] low_m;
    reg [22:0] high_m

    assign e1 = rs1[30:23];
    assign e2 = rs2[30:23];
    assign s1 = rs1[31];
    assign s2 = rs2[31];
    assign m1 = rs1[22:0];
    assign m2 = rs2[22:0];

    //combinational stages
    always@(*)
        //stage1
        //check exponent
        if (e1 > e2) begin
            e_diff = e1-e2;
            low_m = m2;
            high_m = m1;
        end
        else begin
            e_diff = e2-e1;
            low_m = m1;
            high_m = m1;
        end

        //stage2
        //stage3
        //stage4

    //pipe
    always@(posedge clk)
endmodule