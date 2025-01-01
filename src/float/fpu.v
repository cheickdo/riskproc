module fpu(
    input clk,
    input resetn,
	input [31:0] rs1,
	input [31:0] rs2,
    input [31:0] rs3,
    input [31:0] fcsr,
    output reg [4:0] fflags,
	output reg [31:0] result
);

//control signals
reg rs2_in, rd_in, frd_in, IR_in, ADDR_in, Done, dout_in, 
  load, store, din_in, G_in,F_in, AddSub, Arith, zero_extend, branch,
    mul_arith, ret, sys_clear, multicycle, count_rst, count_en, u_op, u2_op;

wire [31:0] fstage;

reg [1:0] Tstep_Q, Tstep_D;
reg valid_en;

always @(posedge clk)
  if (!resetn) Tstep_Q <= exec;
  else Tstep_Q <= Tstep_D;

//Valid mux
always@(posedge clk) begin
  if (!resetn) begin
    Sum_valid = 1'b0;
  end
  else if (data_out_valid & valid_en) begin
    Sum_valid = 1'b1;
  end
  else begin
    Sum_valid = 1'b0;
  end
end

// Control FSM state table (Next State Logic). TODO move it to seperate module?
// Is a function of current state (Tstep_Q) and inputs (run and Done)
always @(*)
  case (Tstep_Q)
    exec: begin
      if (multicycle) Tstep_D = fexec;
      else Tstep_D = access;
    end
    fexec: begin
      if (~multicycle) Tstep_D = access;
      else Tstep_D = fexec;
    end
    default: ;
  endcase

//multicycle counter
counter fstage0 (
  .clk(clk),
  .resetn(resetn & ~count_rst),
  .enable(count_en),
  .out(fstage)
);

//Control logic
always@(*) begin
    multicycle = 1'b0;
    count_rst = 1'b0;
    count_en = 1'b0;
    valid_en = 1'b0;
    operation = 0;

    case (Tstep_Q)
        exec:
            case (opcode)
            F_type: begin 
                case (funct7)
                7'b0001000: begin //fmul
                    operation = 2;
                    multicycle = 1'b1;
                    count_rst = 1'b1;
                end
                7'b0001100: begin //fdiv
                    operation = 3;
                    multicycle = 1'b1;
                    count_rst = 1'b1;
                end
                7'b0101100: begin //fsqrt
                    operation = 17;
                    multicycle = 1'b1;
                    count_rst = 1'b1;
                end
                7'b0000000: begin //floating point add instruction
                    operation = 0;
                    multicycle = 1'b1;
                    count_rst = 1'b1;
                end
                7'b0000100: begin //floating point sub instruction
                    operation = 1;
                    multicycle = 1'b1;
                    count_rst = 1'b1;
                end
                7'b1010000: begin
                    valid_en = 1'b1;
                    if (funct3 == 1) operation = 14; //flt
                    if (funct3 == 0) operation = 15; //fle
                    if (funct3 == 2) operation = 16; //feq
                end
                7'b0010000: begin
                    valid_en = 1'b1;
                    if (funct3 == 0) operation = 11; //fsgnj.s
                    if (funct3 == 1) operation = 12; //fsgnjn.s
                    if (funct3 == 2) operation = 13; //fsgnjx.s
                end
                7'b0010100: begin
                    valid_en = 1'b1;
                    if (funct3 == 0) operation = 9; //fmin
                    if (funct3 == 1) operation = 10; //fmax
                end
                7'b1101000: begin //convert integer to float
                    valid_en = 1'b1;
                    if (rs2 == 5'b00000) operation = 4;
                    if (rs2 == 5'b00001) operation = 5;          

                end
                7'b1111000: begin //move integer to float
                    valid_en = 1'b1;
                    //TODO introduce some bypass
                end
                7'b1110000: begin 
                    valid_en = 1'b1;
                    if (funct3 == 3'b001) operation = 8; //fclass
                    if (rs2 == 5'b00000) begin //move float to integer
                        //introduce some bypass logic
                    end
                end
                7'b1100000: begin //fcvt.w.s TODO
                    valid_en = 1'b1;
                    if (rs2 == 5'b00000) operation = 6;
                    if (rs2 == 5'b00001) operation = 7;
                end
                default: ;
                endcase
            end

            //TODO work on FM instructions after adding new issue queue with 3 operands for floats
            FMADD_type: begin
                operation = 18;
                multicycle = 1'b1;
                count_rst = 1'b1;
            end

            FMSUB_type: begin
                operation = 19;
                multicycle = 1'b1;
                count_rst = 1'b1;
            end

            FNMADD_type: begin
                operation = 20;
                multicycle = 1'b1;
                count_rst = 1'b1;
            end

            FNMSUB_type: begin
                operation = 21;
                multicycle = 1'b1;
                count_rst = 1'b1;
            end

            default: ;
            endcase
        fexec: //multicycle floating point instructions
            case(opcode)
                F_type:  
                case (funct7)
                    7'b0000000: begin //floating point add instruction
                        operation = 0;
                        if (fstage[4:0] == 2) begin 
                            multicycle = 1'b0; 
                            valid_en = 1'b1; 
                        end
                        else multicycle = 1'b1;
                        count_en = 1'b1;
                    end
                    7'b0000100: begin //floating point add instruction
                        operation = 1;
                        if (fstage[4:0] == 2) begin 
                            multicycle = 1'b0; 
                            valid_en = 1'b1; 
                            end
                        else multicycle = 1'b1;
                        count_en = 1'b1;
                    end
                    7'b0001000: begin //fmul
                        operation = 2;
                        if (fstage[4:0] == 2) 
                        begin 
                            multicycle = 1'b0; 
                            valid_en = 1'b1; 
                        end
                        else 
                        multicycle = 1'b1;
                        count_en = 1'b1;
                    end
                    7'b0001100: begin //fdiv
                        operation = 3;
                        if (fstage[4:0] == 26) 
                        begin 
                            multicycle = 1'b0; 
                            valid_en = 1'b1; 
                        end
                        else 
                        multicycle = 1'b1;
                        count_en = 1'b1;
                    end
                    7'b0101100: begin //fsqrt
                        operation = 17;
                        if (fstage[4:0] == 26) 
                        begin 
                            multicycle = 1'b0; 
                            valid_en = 1'b1; 
                        end
                        else 
                        multicycle = 1'b1;
                        count_en = 1'b1;
                    end
                    default: ;
                endcase

                //TODO work on FM instructions after adding new issue queue with 3 operands for floats
                FMADD_type: begin //floating point add instruction
                    operation = 18;
                    if (fstage[4:0] == 5) 
                    begin 
                        multicycle = 1'b0; 
                        valid_en = 1'b1; 
                    end
                    else 
                    multicycle = 1'b1;
                    count_en = 1'b1;
                end

                FMSUB_type: begin //floating point add instruction
                    operation = 19;
                    if (fstage[4:0] == 5) 
                    begin 
                        multicycle = 1'b0; 
                        valid_en = 1'b1; 
                    end
                    else 
                    multicycle = 1'b1;
                    count_en = 1'b1;
                end

                FNMADD_type: begin //floating point add instruction
                    operation = 20;
                    if (fstage[4:0] == 5) 
                    begin 
                        multicycle = 1'b0; 
                        valid_en = 1'b1; 
                    end
                    else multicycle = 1'b1;
                    count_en = 1'b1;
                end

                FNMSUB_type: begin //floating point add instruction
                    operation = 21;
                    if (fstage[4:0] == 5) 
                    begin 
                        multicycle = 1'b0; 
                        valid_en = 1'b1; 
                    end
                    else multicycle = 1'b1;
                    count_en = 1'b1;
                end
                default: ;
            endcase
        default: ;
    endcase
end

parameter FLEN = 32;

reg [FLEN-1:0] G;

wire [FLEN-1:0] fpadd_out, fmul_out, fdiv_out, fpsqrt_out, fcvt_s_w_out, fcvt_s_wu_out, fcvt_w_s_out, fcvt_wu_s_out, fclass_out, fmin_out, fmax_out;
wire [FLEN-1:0] fsgnj_s_out, fsgnjn_s_out, fsgnjx_s_out, fle_out, flt_out, feq_out, fsub_out, fmadd_s_out, fmsub_s_out, fnmadd_s_out, fnmsub_s_out;

wire NX, UF, OF, DZ, NV;
wire [2:0] rounding;

//CSR assignments
assign NX = fcsr[0];
assign UF = fcsr[1];
assign OF = fcsr[2];
assign DZ = fcsr[3];
assign NV = fcsr[4];

assign rounding = fcsr[7:5];

always@(posedge clk) begin
    if (!resetn) fflags <= 0;
    else if (operation == 3) fflags[3] <= 1;
end

always@(*)
    case(operation)
        0: result = fpadd_out;
        1: result = fsub_out;
        2: result = fmul_out;
        3: result = fdiv_out;
        4: result = fcvt_s_w_out;
        5: result = fcvt_s_wu_out;
        6: result = fcvt_w_s_out;
        7: result = fcvt_wu_s_out;
        8: result = fclass_out;
        9: result = fmin_out;
        10: result = fmax_out;
        11: result = fsgnj_s_out;
        12: result = fsgnjn_s_out;
        13: result = fsgnjx_s_out;
        14: result = flt_out;
        15: result = fle_out;
        16: result = feq_out;
        17: result = fpsqrt_out;
        18: result = fmadd_s_out;
        19: result = fmsub_s_out;
        20: result = fnmadd_s_out;
        21: result = fnmsub_s_out;
        default:result = 0;
    endcase

//operation instantiations
fpadd fpu0(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .out(fpadd_out)
);

fpadd fpu17(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2({~rs2[31], rs2[30:0]}),
    .out(fsub_out)
);

fmul fpu1(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .out(fmul_out)
);

fdiv fpu2(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .out(fdiv_out)
);

fsqrt fpu3(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .out(fpsqrt_out)
);

fcvt_s_w fpu4(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .out(fcvt_s_w_out)
);

fcvt_s_wu fpu5(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .out(fcvt_s_wu_out)
);

fcvt_w_s fpu6(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .out(fcvt_w_s_out)
);

fcvt_wu_s fpu7(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .out(fcvt_wu_s_out)
);

fclass fpu8(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .out(fclass_out)
);
fmin fpu9(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .out(fmin_out)
);

fmax fpu10(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .out(fmax_out)
);

fsgnj_s fpu11(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .out(fsgnj_s_out)
);

fsgnjn_s fpu12(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .out(fsgnjn_s_out)
);

fsgnjx_s fpu13(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .out(fsgnjx_s_out)
);

flt fpu14(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .out(flt_out)
);

fle fpu15(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .out(fle_out)
);

feq fpu16(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .out(feq_out)
);

fmadd_s fpu18(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .rs3(rs3),
    .out(fmadd_s_out)
);

fmadd_s fpu19(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .rs3({~rs3[31], rs3[30:0]}),
    .out(fmsub_s_out)
);

fnmadd_s fpu20(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .rs3(rs3),
    .out(fnmadd_s_out)
);

fnmadd_s fpu21(
    .clk(clk),
    .resetn(resetn),
    .rs1(rs1),
    .rs2(rs2),
    .rs3({~rs3[31], rs3[30:0]}),
    .out(fnmsub_s_out)
);

// Dump waves
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, fpu);
end

endmodule