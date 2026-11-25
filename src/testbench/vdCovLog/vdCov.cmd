gui_set_pref_value -category {coveragesetting} -key {geninfodumping} -value 1
gui_exclusion -set_force true
gui_assert_mode -mode flat
gui_class_mode -mode hier
gui_excl_mgr_flat_list -on  0
gui_covdetail_select -id  CovDetail.1   -name   Line
verdiWindowWorkMode -win $_vdCoverage_1 -coverageAnalysis
gui_open_cov  -hier simv.vdb -testdir  {simv.vdb} -test { simv/test } -merge MergedTest -db_max_tests 10 -fsm transition
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} top
gui_list_select -id CoverageTable.1 -list covtblInstancesList { top.dut   }
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} top.dut
gui_list_select -id CoverageTable.1 -list covtblInstancesList { top.dut  top.dut.fpu   }
gui_list_action -id  CoverageTable.1 -list {covtblInstancesList} top.dut.fpu  -column {} 
gui_covdetail_select -id  CovDetail.1   -name   Toggle
gui_covdetail_select -id  CovDetail.1   -name   FSM
gui_covdetail_select -id  CovDetail.1   -name   Condition
gui_list_select -id CovDetail.1 -list cond { {((a_reg[14:10] == 5'b0) || (a_reg[14:10] == 5'h1f) || (b_reg[14:10] == 5'b0) || (b_reg[14:10] == 5'h1f))}   }
vdCovExit -noprompt
