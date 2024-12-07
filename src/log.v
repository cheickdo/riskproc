//big combinational block
function integer log;
    input [size-1:0] in;
    integer i;

    parameter size = 32;
    //log = $clog2(in);
    casez(in)
        32'b00000000000000000000000000000001: log = 0;
        32'b0000000000000000000000000000001z: log = 1;
        32'b000000000000000000000000000001zz: log = 2;
        32'b00000000000000000000000000001zzz: log = 3;
        32'b0000000000000000000000000001zzzz: log = 4;
        32'b000000000000000000000000001zzzzz: log = 5;
        32'b00000000000000000000000001zzzzzz: log = 6;
        32'b0000000000000000000000001zzzzzzz: log = 7;
        32'b000000000000000000000001zzzzzzzz: log = 8;
        32'b00000000000000000000001zzzzzzzzz: log = 9;
        32'b0000000000000000000001zzzzzzzzzz: log = 10;
        32'b000000000000000000001zzzzzzzzzzz: log = 11;
        32'b00000000000000000001zzzzzzzzzzzz: log = 12;
        32'b0000000000000000001zzzzzzzzzzzzz: log = 13;
        32'b000000000000000001zzzzzzzzzzzzzz: log = 14;
        32'b00000000000000001zzzzzzzzzzzzzzz: log = 15;
        32'b0000000000000001zzzzzzzzzzzzzzzz: log = 16;
        32'b000000000000001zzzzzzzzzzzzzzzzz: log = 17;
        32'b00000000000001zzzzzzzzzzzzzzzzzz: log = 18;
        32'b0000000000001zzzzzzzzzzzzzzzzzzz: log = 19;
        32'b000000000001zzzzzzzzzzzzzzzzzzzz: log = 20;
        32'b00000000001zzzzzzzzzzzzzzzzzzzzz: log = 21;
        32'b0000000001zzzzzzzzzzzzzzzzzzzzzz: log = 22;
        32'b000000001zzzzzzzzzzzzzzzzzzzzzzz: log = 23;
        32'b00000001zzzzzzzzzzzzzzzzzzzzzzzz: log = 24;
        32'b0000001zzzzzzzzzzzzzzzzzzzzzzzzz: log = 25;
        32'b000001zzzzzzzzzzzzzzzzzzzzzzzzzz: log = 26;
        32'b00001zzzzzzzzzzzzzzzzzzzzzzzzzzz: log = 27;
        32'b0001zzzzzzzzzzzzzzzzzzzzzzzzzzzz: log = 28;
        32'b001zzzzzzzzzzzzzzzzzzzzzzzzzzzzz: log = 29;
        32'b01zzzzzzzzzzzzzzzzzzzzzzzzzzzzzz: log = 30;
        32'b1zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz: log = 31;
        default: log = 0;
    endcase

endfunction