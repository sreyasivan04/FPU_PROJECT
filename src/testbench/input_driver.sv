class input_driver extends uvm_driver#(trans);
	`uvm_component_utils(input_driver)
virtual fpu_if.INP_DRV vif;
fpu_config m_cfg;

function new(string name="input_driver",uvm_component parent);
	super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
if(!uvm_config_db#(fpu_config)::get(this,"","fpu_config",m_cfg))
	`uvm_fatal(get_type_name(),"Input driver getting failed")
endfunction

function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	vif=m_cfg.vif;
endfunction

task run_phase(uvm_phase phase);
	//wait(m_cfg.vif.rst_n==1'b1);
	forever 
		begin
			wait(m_cfg.vif.rst_n==1'b1);
			seq_item_port.get_next_item(req);
			drive(req);
			seq_item_port.item_done();
		end
endtask

task drive(trans data2duv);
	begin
		`uvm_info("INPUT_DRIVER",$sformatf("Input driver\n%s",data2duv.sprint()),UVM_NONE)
		@(vif.inp_drv_cb);
		vif.inp_drv_cb.ui_in<=data2duv.ui_in;
		vif.inp_drv_cb.uio_in<=data2duv.uio_in;
	end
endtask
endclass
