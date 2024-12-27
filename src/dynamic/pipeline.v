module pipline();

//instantiate dispatcher and send data to it
dispatcher d0(
    .clk(clk),
    .resetn(resetn),
    .enq_ifq(enq_ifq),
    .deq_ifq(deq_ifq),
    .data_in_ifq(data_in_ifq),
    .full_intalu(full_intalu),
    .full_fpalu(full_fpalu),
    .full_agu(full_agu),
    .full_ifq(full_ifq),
    .empty_ifq(empty_ifq),
    .enq_intalu(enq_intalu),
    .enq_fpalu(enq_fpalu),
    .enq_agu(enq_agu),
    .intalu_data_i(intalu_data_i),
    .fpalu_data_i(fpalu_data_i),
    .agu_data_i(agu_data_i)
);

//instantiate issue queues and send data to them

//instantiate functional units and send data to them

//instantiate writeback unit and send data to it


endmodule