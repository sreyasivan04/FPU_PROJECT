interface fpu_if(input logic clk,input logic rst_n);
logic [7:0] ui_in;
logic [7:0] uio_in;
logic [7:0] uo_out;
logic [7:0] uio_out;
logic [7:0] uio_oe;

clocking inp_drv_cb@(posedge clk);
	default input #1 output #1;
	output ui_in;
	output uio_in;
endclocking
clocking inp_mon_cb@(posedge clk);
	default input #1 output #1;
	input rst_n;
	input ui_in;
	input uio_in;
endclocking
clocking out_mon_cb@(posedge clk);
	default input #1 output #1;
	input rst_n;
	input ui_in;
	input uio_in;
	input uo_out;
	input uio_out;
	input uio_oe;
endclocking
modport INP_DRV(clocking inp_drv_cb);
modport INP_MON(clocking inp_mon_cb);
modport OUT_MON(clocking out_mon_cb);
endinterface
