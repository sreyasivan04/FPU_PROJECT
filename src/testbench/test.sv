class test extends uvm_test;

  `uvm_component_utils(test)

  fpu_env env_h;
        fpu_config m;

  function new(string name="test",uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
                m=fpu_config::type_id::create("m");
                if(!uvm_config_db#(virtual fpu_if)::get(this,"","fpu_if",m.vif))
                                                `uvm_fatal(get_type_name(),"can't get the interface")
                m.input_agent_is_active=UVM_ACTIVE;
                m.output_agent_is_active=UVM_PASSIVE;
                uvm_config_db#(fpu_config)::set(this,"*","fpu_config",m);
    env_h=fpu_env::type_id::create("env_h",this);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction

        function void start_of_simulation_phase(uvm_phase phase);
                super.start_of_simulation_phase(phase);
                `uvm_info(get_type_name(),"simulation started",UVM_LOW)
        endfunction

        task run_phase(uvm_phase phase);
                phase.raise_objection(this);
                `uvm_info(get_type_name(),"base test running",UVM_LOW)
                phase.drop_objection(this);
        endtask

endclass


class normal_add_test extends test;

  `uvm_component_utils(normal_add_test)

  normal_add_seq seq1;
        normal_sub_seq seq2;
        negative_add_seq seq3;
        mixed_sign_add_seq seq4;
        mixed_sign_sub_seq seq5;
        positive_inf_seq seq6;
        nan_seq seq7;
        denormal_seq seq8;
        equal_sub_seq seq9;
        random_normal_add_seq seq10;
        zero_minus_nonzero_seq seq11;
        start_before_operands_seq seq12;
        equal_exponent_add_seq seq13;
        different_exponent_add_seq seq14;
        carry_out_add_seq seq15;
        exponent_overflow_add_seq seq16;
        underflow_sub_seq seq17;
        max_normal_exponent_add_seq seq18;
        leading_zero_sub_seq seq19;
        we_re_sequence seq20;
        random_normal_sub_seq seq21;
  write_start_coverage_seq seq22;
        ui_upper_nibble_seq seq23;
        start_before_ready_seq seq24;
        read_request_while_busy_seq seq25;
        sub_start_low_seq seq26;
        coverage_fix_seq seq27;
        coverage_fix_seq2 seq28;
        coverage_fix_seq3 seq29;
  function new(string name="normal_add_test",uvm_component parent=null);

    super.new(name,parent);

  endfunction

  task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    seq1=normal_add_seq::type_id::create("seq1");

    seq1.start(env_h.inp_agt_h.seqr_h);
                seq2=normal_sub_seq::type_id::create("seq2");
                seq2.start(env_h.inp_agt_h.seqr_h);
                seq3=negative_add_seq::type_id::create("seq3");
                seq3.start(env_h.inp_agt_h.seqr_h);
                seq4=mixed_sign_add_seq::type_id::create("seq4");
                seq4.start(env_h.inp_agt_h.seqr_h);
                seq5=mixed_sign_sub_seq::type_id::create("seq5");
                seq5.start(env_h.inp_agt_h.seqr_h);
                seq6=positive_inf_seq::type_id::create("seq6");
                seq6.start(env_h.inp_agt_h.seqr_h);
                seq7=nan_seq::type_id::create("seq7");
                seq7.start(env_h.inp_agt_h.seqr_h);
                seq8=denormal_seq::type_id::create("seq8");
                seq8.start(env_h.inp_agt_h.seqr_h);
                seq9=equal_sub_seq::type_id::create("seq9");
                seq9.start(env_h.inp_agt_h.seqr_h);
                seq10=random_normal_add_seq::type_id::create("seq10");
                seq10.start(env_h.inp_agt_h.seqr_h);
                seq11=zero_minus_nonzero_seq::type_id::create("seq11");
                seq11.start(env_h.inp_agt_h.seqr_h);
                seq12=start_before_operands_seq::type_id::create("seq12");
                seq12.start(env_h.inp_agt_h.seqr_h);
                seq13=equal_exponent_add_seq::type_id::create("seq13");
                seq13.start(env_h.inp_agt_h.seqr_h);
                seq14=different_exponent_add_seq::type_id::create("seq14");
                seq14.start(env_h.inp_agt_h.seqr_h);
                seq15=carry_out_add_seq::type_id::create("seq15");
                seq15.start(env_h.inp_agt_h.seqr_h);
                seq16=exponent_overflow_add_seq::type_id::create("seq16");
                seq16.start(env_h.inp_agt_h.seqr_h);
                seq17=underflow_sub_seq::type_id::create("seq17");
                seq17.start(env_h.inp_agt_h.seqr_h);
                seq18=max_normal_exponent_add_seq::type_id::create("seq18");
                seq18.start(env_h.inp_agt_h.seqr_h);
                seq19=leading_zero_sub_seq::type_id::create("seq19");
                seq19.start(env_h.inp_agt_h.seqr_h);
                //#200ns;
                seq20=we_re_sequence::type_id::create("seq20");
                seq20.start(env_h.inp_agt_h.seqr_h);
    seq21=random_normal_sub_seq::type_id::create("seq21");
                seq21.start(env_h.inp_agt_h.seqr_h);
                seq22=write_start_coverage_seq::type_id::create("seq22");
                seq22.start(env_h.inp_agt_h.seqr_h);
                seq23=ui_upper_nibble_seq::type_id::create("seq23");
                seq23.start(env_h.inp_agt_h.seqr_h);
                seq24=start_before_ready_seq::type_id::create("seq24");
                seq24.start(env_h.inp_agt_h.seqr_h);
                seq25=read_request_while_busy_seq::type_id::create("seq25");
                seq25.start(env_h.inp_agt_h.seqr_h);
                seq26=sub_start_low_seq::type_id::create("seq26");
                seq26.start(env_h.inp_agt_h.seqr_h);
                seq27=coverage_fix_seq::type_id::create("seq27");
                seq27.start(env_h.inp_agt_h.seqr_h);
                seq28=coverage_fix_seq2::type_id::create("seq28");
                seq28.start(env_h.inp_agt_h.seqr_h);
                seq29=coverage_fix_seq3::type_id::create("seq29");
                seq29.start(env_h.inp_agt_h.seqr_h);
    phase.drop_objection(this);

  endtask

endclass
