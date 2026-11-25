class fpu_env extends uvm_env;
	`uvm_component_utils(fpu_env)
input_agent inp_agt_h;
output_agent out_agt_h;
scoreboard sb_h;
fpu_coverage cov_h;
fpu_config m_cfg;

function new(string name="fpu_env",uvm_component parent);
	super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
if(!uvm_config_db#(fpu_config)::get(this,"","fpu_config",m_cfg))
	`uvm_fatal(get_type_name(),"env getting failed")
inp_agt_h=input_agent::type_id::create("inp_agt_h",this);
out_agt_h=output_agent::type_id::create("out_agt_h",this);
sb_h=scoreboard::type_id::create("sb_h",this);
cov_h=fpu_coverage::type_id::create("cov_h",this);
endfunction

function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
inp_agt_h.mon_h.inp_monitor_port.connect(sb_h.inp_mon_fifo.analysis_export);
out_agt_h.mon_h.out_monitor_port.connect(sb_h.out_mon_fifo.analysis_export);
inp_agt_h.mon_h.inp_monitor_port.connect(cov_h.analysis_export);
endfunction
endclass
