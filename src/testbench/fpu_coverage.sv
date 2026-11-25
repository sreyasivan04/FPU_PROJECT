
class fpu_coverage extends uvm_subscriber #(trans);

  `uvm_component_utils(fpu_coverage)

  typedef enum {FP_ZERO, FP_DENORMAL, FP_NORMAL, FP_INFINITY, FP_NAN} fp_type_e;

  bit write_en, read_en, start, opcode;
  bit prev_wr, prev_st;

  int wr_cnt;
  bit [`WIDTH-1:0] op_a, op_b;

  fp_type_e a_type, b_type;
  bit sign_a, sign_b;

  covergroup cg_ctrl;

    write_en: coverpoint write_en {
      bins LOW  = {0};
      bins HIGH = {1};
    }

    read_en: coverpoint read_en {
      bins LOW  = {0};
      bins HIGH = {1};
    }

    start: coverpoint start {
      bins LOW  = {0};
      bins HIGH = {1};
    }

  endgroup

  covergroup cg_op;

    opcode: coverpoint opcode {
      bins ADD = {0};
      bins SUB = {1};
    }

    operand_a_type: coverpoint a_type {
      bins zero     = {FP_ZERO};
      bins denormal = {FP_DENORMAL};
      bins normal   = {FP_NORMAL};
      bins infinity = {FP_INFINITY};
      bins NaN      = {FP_NAN};
    }

    operand_b_type: coverpoint b_type {
      bins zero     = {FP_ZERO};
      bins denormal = {FP_DENORMAL};
      bins normal   = {FP_NORMAL};
      bins infinity = {FP_INFINITY};
      bins NaN      = {FP_NAN};
    }

    sign_A: coverpoint sign_a {
      bins positive = {0};
      bins negative = {1};
    }

    sign_B: coverpoint sign_b {
      bins positive = {0};
      bins negative = {1};
    }

    opcode_x_signA: cross opcode, sign_A;
    opcode_x_signB: cross opcode, sign_B;

  endgroup

  function new(string name = "fpu_coverage", uvm_component parent);
    super.new(name, parent);
    cg_ctrl = new();
    cg_op = new();
  endfunction

  function fp_type_e classify(bit [`WIDTH-1:0] v);

    bit [`EXP_W-1:0] e;
    bit [`MAN_W-1:0] m;

    e = v[`WIDTH-2 -: `EXP_W];
    m = v[`MAN_W-1:0];

    if (e == '0)
      return (m == '0) ? FP_ZERO : FP_DENORMAL;
    else if (e == '1)
      return (m == '0) ? FP_INFINITY : FP_NAN;
    else
      return FP_NORMAL;

  endfunction

  virtual function void write(trans t);

    int idx;

    write_en = t.ui_in[0];
    read_en  = t.ui_in[1];
    start    = t.ui_in[2];
    opcode   = t.ui_in[3];

    if (write_en && !prev_wr) begin

      idx = wr_cnt % `TOTAL_BYTES;

      if (idx < `BYTES_PER_OP)
        op_a[8*idx +: 8] = t.uio_in;
      else
        op_b[8*(idx - `BYTES_PER_OP) +: 8] = t.uio_in;

      wr_cnt = (wr_cnt + 1) % `TOTAL_BYTES;

    end

    cg_ctrl.sample();

    if (start && !prev_st) begin

      a_type = classify(op_a);
      b_type = classify(op_b);

      sign_a = op_a[`WIDTH-1];
      sign_b = op_b[`WIDTH-1];

      cg_op.sample();

    end

    prev_wr = write_en;
    prev_st = start;

    `uvm_info(get_type_name(), "INPUT TRANSACTION RECEIVED", UVM_HIGH)

  endfunction

  function void report_phase(uvm_phase phase);

    super.report_phase(phase);

    `uvm_info(get_type_name(),
      $sformatf("CONTROL COVERAGE = %0.2f %%",
      cg_ctrl.get_coverage()), UVM_NONE)

    `uvm_info(get_type_name(),
      $sformatf("OPERATION COVERAGE = %0.2f %%",
      cg_op.get_coverage()), UVM_NONE)

    `uvm_info(get_type_name(),
      $sformatf("TOTAL INPUT COVERAGE = %0.2f %%",
      (cg_ctrl.get_coverage() + cg_op.get_coverage()) / 2.0), UVM_NONE)

  endfunction

endclass

