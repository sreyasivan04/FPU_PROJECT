`timescale 1ns/1ns
`include "uvm_macros.svh"
`include "fpu_defines.svh"
//`include "fpu_test_pkg.sv"
//`include "fpu_if.sv"
//`include "tt_um_project_fpu.v"
//`include "fpu_assertions.sv"
module top;

 import uvm_pkg::*;
  import fpu_test_pkg::*;

  bit clk;
  bit rst_n;

  fpu_if DUV_IF(clk, rst_n);

  initial begin
    rst_n = 0;
    #80 rst_n = 1;
  end

  tt_um_project_fpu #(.EXP_W(5), .MAN_W(10)) dut (
    .ui_in   (DUV_IF.ui_in),
    .uo_out  (DUV_IF.uo_out),
    .uio_in  (DUV_IF.uio_in),
    .uio_out (DUV_IF.uio_out),
    .uio_oe  (DUV_IF.uio_oe),
    .ena     (1'b1),
    .clk     (clk),
    .rst_n   (rst_n)
  );

        bind tt_um_project_fpu fpu_assertions fpu(.*);



  initial begin
    clk = 0;
    forever #20 clk = ~clk;
  end



  initial begin
    uvm_config_db#(virtual fpu_if)::set(null, "*", "fpu_if", DUV_IF);

    $dumpfile("fpu.vcd");
    $dumpvars(0, top);

    run_test();
  end

endmodule
