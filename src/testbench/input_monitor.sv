class input_monitor extends uvm_monitor;
	`uvm_component_utils(input_monitor)
uvm_analysis_port#(trans) inp_monitor_port;
virtual fpu_if.INP_MON vif;
fpu_config m_cfg;

function new(string name="input_monitor",uvm_component parent);
	super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
if(!uvm_config_db#(fpu_config)::get(this,"","fpu_config",m_cfg))
	`uvm_fatal(get_type_name(),"Input monitor getting failed")
inp_monitor_port=new("inp_monitor_port",this);
endfunction

function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	vif=m_cfg.vif;
endfunction

task run_phase(uvm_phase phase);
	forever begin
		collect_input_monitor();
	end
endtask

virtual task collect_input_monitor();
	trans drv2mon;
	begin
		@(vif.inp_mon_cb);
		drv2mon=trans::type_id::create("drv2mon");
		drv2mon.rst_n=vif.inp_mon_cb.rst_n;
		drv2mon.ui_in=vif.inp_mon_cb.ui_in;
		drv2mon.uio_in=vif.inp_mon_cb.uio_in;
		inp_monitor_port.write(drv2mon);
		`uvm_info("INPUT_MONITOR",$sformatf("Input monitor\n%s",drv2mon.sprint()),UVM_NONE)
	end
endtask
endclass
