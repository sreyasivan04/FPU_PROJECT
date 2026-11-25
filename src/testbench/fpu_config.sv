class fpu_config extends uvm_object;
	`uvm_object_utils(fpu_config)
	virtual fpu_if vif;
	uvm_active_passive_enum input_agent_is_active;
	uvm_active_passive_enum output_agent_is_active;

	function new(string name="fpu_config");
		super.new(name);
		endfunction
		endclass
