class output_monitor extends uvm_monitor;
	`uvm_component_utils(output_monitor)
uvm_analysis_port#(trans) out_monitor_port;
virtual fpu_if.OUT_MON vif;
fpu_config m;
//trans rd_data;

function new(string name="output_monitor",uvm_component parent);
	super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
if(!uvm_config_db#(fpu_config)::get(this,"","fpu_config",m))
	`uvm_fatal(get_type_name(),"output monitor failed")
out_monitor_port=new("out_monitor_port",this);
endfunction

function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
vif=m.vif;
endfunction

task run_phase(uvm_phase phase);
	forever
		begin
			collect_data();
		end
endtask

virtual task collect_data();
	trans rd_data;
	begin
		@(vif.out_mon_cb);
		rd_data=trans::type_id::create("rd_data");
		rd_data.rst_n=vif.out_mon_cb.rst_n;
		rd_data.uo_out=vif.out_mon_cb.uo_out;
		rd_data.uio_out=vif.out_mon_cb.uio_out;
		rd_data.uio_oe=vif.out_mon_cb.uio_oe;
		rd_data.ui_in=vif.out_mon_cb.ui_in;
		rd_data.uio_in=vif.out_mon_cb.uio_in;

		out_monitor_port.write(rd_data);
	`uvm_info("OUTPUT_MONITOR",$sformatf("OUTPUT MONITOR\n%s",rd_data.sprint()),UVM_NONE)
	
end
endtask
endclass
