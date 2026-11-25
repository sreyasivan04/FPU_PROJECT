`include "fpu_defines.svh"
class trans extends uvm_sequence_item;
rand bit [7:0] ui_in;
rand bit [7:0] uio_in;
logic [7:0] uo_out;
logic [7:0] uio_out;
logic [7:0] uio_oe;
bit rst_n;
`uvm_object_utils_begin(trans)
	`uvm_field_int(ui_in,UVM_ALL_ON)
	`uvm_field_int(uio_in,UVM_ALL_ON)
	`uvm_field_int(uo_out,UVM_ALL_ON)
	`uvm_field_int(uio_out,UVM_ALL_ON)
	`uvm_field_int(uio_oe,UVM_ALL_ON)
	`uvm_field_int(rst_n,UVM_ALL_ON)
`uvm_object_utils_end

function new(string name="trans");
	super.new(name);
endfunction
endclass

 
