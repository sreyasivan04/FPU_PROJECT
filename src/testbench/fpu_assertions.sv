module fpu_assertions(
  input logic clk,
  input logic rst_n,
        input logic [15:0] a_reg,
        input logic [15:0] b_reg,
  input logic [7:0] ui_in,
  input logic [7:0] uo_out,
  input logic [7:0] uio_out,
  input logic [7:0] uio_oe
);

  wire start = ui_in[2];
  wire busy  = uo_out[0];
  wire done  = uo_out[1];
  wire error = uo_out[2];
  wire ready = uo_out[3];
        wire special_operation=(a_reg[14:10]==0)||(a_reg[14:10]==31)||(b_reg[14:10]==0)||(b_reg[14:10]==31);
        wire normal_operation=!special_operation;


  // reset check
  property reset_check;
    @(posedge clk)
    !rst_n |-> (uo_out == 8'h00 &&
                uio_out == 8'h00 &&
                uio_oe == 8'h00);
  endproperty

  assert property(reset_check)
                $display("pass reset check");
  else
                                        $error("Reset check failed");

  // start and busy check
 property start_busy_check;
    @(posedge clk) disable iff(!rst_n)
    (start && ready && !busy && $time==1020ns) |=> busy;
  endproperty

  assert property(start_busy_check)
                $display("pass start busy check");
  else
                                        $error("Start busy check failed");

  // busy and done should not be high simultaneously
  property busy_done_check;
    @(posedge clk) disable iff(!rst_n)
    !(busy && done);
  endproperty

  assert property(busy_done_check)
                $display("pass busy done check");
  else
                                        $error("Busy done check failed");

  // start should be accepted only when ready and not busy
  property valid_start_check;
    @(posedge clk) disable iff(!rst_n)
    start |-> (ready && !busy);
  endproperty

  assert property(valid_start_check)
    else $error("Valid start check failed");

  // error should imply done
  property error_done_check;
    @(posedge clk) disable iff(!rst_n)
    error |-> done;
  endproperty

  assert property(error_done_check)
                $display("pass error done check");
  else
                                        $error("Error done check failed");

  // ready and busy should not be high simultaneously
  property ready_busy_check;
    @(posedge clk) disable iff(!rst_n)
    !(ready && busy);
  endproperty

  assert property(ready_busy_check)
                $display("pass ready busy check");
  else
                                        $error("Ready busy check failed");

  // start without ready should not start the operation
  property start_validity_check;
    @(posedge clk) disable iff(!rst_n)
    (start && !ready) |=> !busy;
  endproperty

  assert property(start_validity_check)
                $display("pass start validity check");
  else
                                        $error("Start validity check failed");
  // normal operation should complete in 4 cycles
  property normal_operation_check;
    @(posedge clk) disable iff(!rst_n)
    (start && ready && !busy && normal_operation)
    |-> ##5 done;
  endproperty

  assert property(normal_operation_check)
                $display("pass normal operation");
  else
                                        $error("Normal operation check failed");

  // special operation should complete in 3 cycles
  property special_operation_check;
    @(posedge clk) disable iff(!rst_n)
    (start && ready && !busy && special_operation)
    |-> ##4 done;
  endproperty

  assert property(special_operation_check)
                $display("pass special operation check");
  else
                                        $error("Special operation check failed");

endmodule
