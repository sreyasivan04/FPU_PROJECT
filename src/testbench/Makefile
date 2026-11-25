
# FPU UVM Makefile

VCS = vcs
URG = urg
SIM = simv

TESTLIST ?= normal_add_test
NUM_RUNS ?= 10
UVM_VERBOSITY ?= UVM_MEDIUM

UVM_OPTS = -ntb_opts uvm-1.2
CM_OPTS = -cm line+cond+fsm+tgl+branch+assert

# Source files
IF_FILE = fpu_if.sv
RTL_FILE = tt_um_project_fpu.v
PKG_FILE = fpu_test_pkg.sv
ASSERT_FILE = fpu_assertions.sv
TOP_FILE = top.sv

INC_DIRS = +incdir+./ +incdir+./rtl

# Coverage directories
OUT_DIR = work
REGR_ROOT = regression_cm
REGR_MERGED = $(REGR_ROOT)/merged
REGR_REPORT = $(REGR_MERGED)/report

.PHONY: all compile run regression merge_regression clean clean_all

all: compile

compile:
	$(VCS) -full64 -sverilog $(UVM_OPTS) \
	-debug_access+all \
	-timescale=1ns/1ns \
	$(CM_OPTS) -assert svaext -lca \
	$(INC_DIRS) \
	$(IF_FILE) $(RTL_FILE) $(PKG_FILE) $(ASSERT_FILE) $(TOP_FILE) \
	-o $(SIM) -l compile.log

run: compile
	./$(SIM) +UVM_TESTNAME=$(TEST) \
	+UVM_VERBOSITY=$(UVM_VERBOSITY) \
	-cm $(CM_OPTS) -l run.log

regression: compile
	mkdir -p $(REGR_ROOT)
	rm -f $(REGR_ROOT)/vdb_list.txt
	@for test in $(TESTLIST); do \
		for run in $$(seq 1 $(NUM_RUNS)); do \
			echo "Running $$test - iteration $$run"; \
			./$(SIM) +UVM_TESTNAME=$$test \
			+UVM_VERBOSITY=$(UVM_VERBOSITY) \
			-cm $(CM_OPTS) \
			-cm_name $${test}_$$run \
			-cm_dir $(REGR_ROOT)/$${test}_$$run.vdb \
			-l $(REGR_ROOT)/$${test}_$$run.log; \
			if grep -Eq "UVM_ERROR|UVM_FATAL" $(REGR_ROOT)/$${test}_$$run.log; then \
				echo "FAILED: $$test iteration $$run"; \
			else \
				echo "PASSED: $$test iteration $$run"; \
			fi; \
			if [ -d $(REGR_ROOT)/$${test}_$$run.vdb ]; then \
				echo $(REGR_ROOT)/$${test}_$$run.vdb >> $(REGR_ROOT)/vdb_list.txt; \
			fi; \
		done; \
	done
	$(MAKE) merge_regression

merge_regression:
	mkdir -p $(REGR_MERGED)
	$(URG) -dir $$(tr '\n' ' ' < $(REGR_ROOT)/vdb_list.txt) \
	-dbname $(REGR_MERGED) -report $(REGR_REPORT)

clean:
	rm -rf csrc simv simv.daidir ucli.key compile.log run.log

clean_all: clean
	rm -rf $(OUT_DIR) $(REGR_ROOT) *.vcd *.fsdb

