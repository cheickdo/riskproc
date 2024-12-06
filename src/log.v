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