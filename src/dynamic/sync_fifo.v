module sync_fifo #(parameter DEPTH = 8, DATA_WIDTH=32) (
  input clk, resetn,
  input enq, deq,
  input [DATA_WIDTH-1:0] data_in,
  output reg [DATA_WIDTH-1:0] data_out,
  output full, empty
);
  
  reg [$clog2(DEPTH)-1:0] w_ptr, r_ptr;
  reg [DATA_WIDTH-1:0] fifo [DEPTH];
  reg [$clog2(DEPTH)-1:0] count;
  
  // Set Default values on reset.
  always@(posedge clk) begin
    if(!resetn) begin
      w_ptr <= 0; r_ptr <= 0;
      data_out <= 0;
      count <= 0;
    end
    else begin
      case({enq,deq})
        2'b00, 2'b11: count <= count;
        2'b01: if (!empty) count <= count - 1'b1;
        2'b10: if (!full) count <= count + 1'b1;
      endcase
    end
  end
  
  // To write data to FIFO
  always@(posedge clk) begin
    if(enq & !full)begin
      fifo[w_ptr] <= data_in;
      w_ptr <= w_ptr + 1;
    end
  end
  
  // To read data from FIFO
  always@(posedge clk) begin
    if(deq & !empty) begin
      data_out <= fifo[r_ptr];
      r_ptr <= r_ptr + 1;
    end
  end
  
  assign full = (count == DEPTH-1);
  assign empty = (count == 0);

    // Dump waves
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(2, sync_fifo);
    end
endmodule