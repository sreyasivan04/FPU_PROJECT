class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)

  uvm_tlm_analysis_fifo#(trans) inp_mon_fifo;
  uvm_tlm_analysis_fifo#(trans) out_mon_fifo;

  // incoming byte order: 1 = first byte written is the LSB
  localparam bit inp_byte_is_lsb = 1'b1;
  // Spec F-006 says the larger operand is returned when the smaller is zero.
  // Set to 1 if the RTL inverts B's sign for SUB when A == 0.
  localparam bit INVERT_B_SIGN_ON_ZERO_SUB = 1'b0;
  // max cycles to wait for done after start
  localparam int TIMEOUT_CYCLES = 30;

  // operands
  bit [7:0]  operand_bytes[4];
  int        write_count;
  bit [15:0] operand_a;
  bit [15:0] operand_b;

  // expected
  bit [15:0] expected_result;
  bit        expected_error;
  bit        expected_special;

  // actual
  bit [7:0]  result_bytes[2];
  bit [15:0] actual_result;
  int        result_count;

  int match_count;
  int mismatch_count;
  int cycle_count;
  int elapsed_cycles;

  bit prev_write;
  bit prev_start;
  bit prev_read;
  bit pending_transaction;
  bit done_seen_low;
  bit read_captured;

  function new(string name = "scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    inp_mon_fifo = new("inp_mon_fifo", this);
    out_mon_fifo = new("out_mon_fifo", this);
  endfunction

  // zero (either sign)
  function bit is_zero(bit [15:0] data);
    return (data[14:0] == 15'h0000);
  endfunction

  // infinity, NaN, denormal
  function bit is_invalid(bit [15:0] data);
    if (data[14:10] == 5'b11111) return 1'b1;
    if (data[14:10] == 5'b00000 && data[9:0] != 10'b0) return 1'b1;
    return 1'b0;
  endfunction

  function void calculate_expected(bit [15:0] a, bit [15:0] b, bit opcode,
                                   output bit [15:0] result,
                                   output bit error_flag,
                                   output bit special_flag);
    bit        sa, sb_eff, sbig;
    bit [14:0] mag_a, mag_b, mag_big, mag_small;
    bit [4:0]  exp_big, exp_small, exp_res;
    bit [10:0] m_big, m_small, diff;
    bit [11:0] sum;
    bit [9:0]  frac;
    int        lz, ediff;
    bit        a_is_big;

    error_flag   = 0;
    special_flag = 0;
    result       = 16'h0000;

    // Inf / NaN / denormal -> error, result 0
    if (is_invalid(a) || is_invalid(b)) begin
      error_flag   = 1;
      special_flag = 1;
      return;
    end

    mag_a  = a[14:0];
    mag_b  = b[14:0];
    sa     = a[15];
    sb_eff = b[15] ^ opcode;

    // zero handling: return the other operand; both zero -> A
    if (mag_a == 0 || mag_b == 0) begin
      special_flag = 1;
      if (mag_a==0 && mag_b == 0)
        result = a;
      else if (mag_a == 0)
        result = {sb_eff,b[14:0]};
      else
        result = a;
      return;
    end

    a_is_big  = (mag_a >= mag_b);
    mag_big   = a_is_big ? mag_a : mag_b;
    mag_small = a_is_big ? mag_b : mag_a;
    sbig      = a_is_big ? sa    : sb_eff;

    exp_big   = mag_big[14:10];
    exp_small = mag_small[14:10];
    m_big     = {1'b1, mag_big[9:0]};
    m_small   = {1'b1, mag_small[9:0]};
    ediff     = exp_big - exp_small;
    m_small   = m_small >> ediff;

    if (sa == sb_eff) begin
      // effective addition
      sum = m_big + m_small;
      if (sum[11]) begin
        if (exp_big == 5'd30) begin   // overflow -> infinity
          result = {sbig, 5'b11111, 10'b0};
          return;
        end
        exp_res = exp_big + 1;
        frac    = sum[10:1];
      end
      else begin
        exp_res = exp_big;
        frac    = sum[9:0];
      end
      result = {sbig, exp_res, frac};
    end
    else begin
      // effective subtraction
      diff = m_big - m_small;
      if (diff == 0) begin            // exact cancellation -> +0
        result = 16'h0000;
        return;
      end
      lz = 0;
      while (!diff[10 - lz]) lz++;
      if (lz >= exp_big) begin        // underflow -> signed zero
        result = {sbig, 15'b0};
        return;
      end
      diff    = diff << lz;
      exp_res = exp_big - lz;
      result  = {sbig, exp_res, diff[9:0]};
    end
  endfunction

  task run_phase(uvm_phase phase);
    trans inp;
    trans out;
    bit   start_edge;
    bit   write_edge;

    cycle_count         = 0;
    write_count         = 0;
    result_count        = 0;
    match_count         = 0;
    mismatch_count      = 0;
    prev_write          = 0;
    prev_start          = 0;
    prev_read           = 0;
    pending_transaction = 0;
    done_seen_low       = 0;
    read_captured       = 0;

    forever begin
      inp_mon_fifo.get(inp);
      out_mon_fifo.get(out);
      cycle_count++;

      // reset
      if (!inp.rst_n || !out.rst_n) begin
        write_count         = 0;
        result_count        = 0;
        pending_transaction = 0;
        done_seen_low       = 0;
        prev_write          = 0;
        prev_start          = 0;
        prev_read           = 0;
        read_captured       = 0;
      end
      else begin
        write_edge = inp.ui_in[0] && !prev_write;
        start_edge = inp.ui_in[2] && !prev_start;

        // ---------------- operand capture ----------------
        // writes while busy are ignored by the DUT
        if (write_edge && write_count < 4 && !out.uo_out[0]) begin
          operand_bytes[write_count] = inp.uio_in;
          `uvm_info("SCOREBOARD", $sformatf("Operand byte %0d=%02h", write_count, inp.uio_in), UVM_MEDIUM)
          write_count++;
          if (write_count == 4) begin
            if (inp_byte_is_lsb) begin
              operand_a = {operand_bytes[1], operand_bytes[0]};
              operand_b = {operand_bytes[3], operand_bytes[2]};
            end
            else begin
              operand_a = {operand_bytes[0], operand_bytes[1]};
              operand_b = {operand_bytes[2], operand_bytes[3]};
            end
            `uvm_info("SCOREBOARD", $sformatf("A=%04h B=%04h", operand_a, operand_b), UVM_MEDIUM)
          end
        end

        // ---------------- start ----------------
        if (start_edge && out.uo_out[3] && !out.uo_out[0]) begin
          if (write_count != 4) begin
            `uvm_error("SCOREBOARD", "Start detected before all four operand bytes were written")
          end
          else begin
            calculate_expected(operand_a, operand_b, inp.ui_in[3],
                               expected_result, expected_error, expected_special);
            pending_transaction = 1;
            done_seen_low       = 0;
            elapsed_cycles      = 0;
            result_count        = 0;
            read_captured       = 0;
            write_count         = 0;
            `uvm_info("SCOREBOARD",
                      $sformatf("START: A=%04h B=%04h Opcode=%0b Expected=%04h ExpErr=%0b",
                                operand_a, operand_b, inp.ui_in[3], expected_result, expected_error),
                      UVM_LOW)
          end
        end
        // ---------------- completion check ----------------
        else if (pending_transaction) begin
          elapsed_cycles++;
          if (out.uo_out[1] === 1'b0)
            done_seen_low = 1;

          if (out.uo_out[1] === 1'b1 && done_seen_low) begin
            `uvm_info("SCOREBOARD", "DUT done signal detected", UVM_MEDIUM)
            if (out.uo_out[2] !== expected_error) begin
              mismatch_count++;
              `uvm_error("SCOREBOARD", $sformatf("Error flag mismatch: Expected=%0b Actual=%0b",
                                                 expected_error, out.uo_out[2]))
            end
            if (out.uo_out[0] !== 1'b0) begin
              mismatch_count++;
              `uvm_error("SCOREBOARD", "Busy should be low after completion")
            end
            pending_transaction = 0;
          end
          else if (elapsed_cycles > TIMEOUT_CYCLES) begin
            mismatch_count++;
            `uvm_error("SCOREBOARD", $sformatf("Timeout: done not seen within %0d cycles of start", TIMEOUT_CYCLES))
            pending_transaction = 0;
          end
        end

        // ---------------- result capture ----------------
        if (!inp.ui_in[1])
          read_captured = 0;

        // read attempted before done
        if (inp.ui_in[1] && !out.uo_out[1] && !read_captured)
          `uvm_warning("SCOREBOARD", "Read attempted before done was asserted")

        // capture once per read pulse
        if (inp.ui_in[1] && out.uo_out[1] && out.uio_oe === 8'hFF && !read_captured) begin
          if (result_count < 2) begin
            result_bytes[result_count] = out.uio_out;
            `uvm_info("SCOREBOARD", $sformatf("Result byte %0d=%02h", result_count, out.uio_out), UVM_MEDIUM)
            result_count++;
            read_captured = 1;
            if (result_count == 2) begin
              actual_result = {result_bytes[1], result_bytes[0]};
              if (actual_result === expected_result) begin
                match_count++;
                `uvm_info("SCOREBOARD", $sformatf("PASS: Expected=%04h Actual=%04h", expected_result, actual_result), UVM_LOW)
              end
              else begin
                mismatch_count++;
                `uvm_error("SCOREBOARD", $sformatf("FAIL: Expected=%04h Actual=%04h", expected_result, actual_result))
              end
            end
          end
        end

        prev_write = inp.ui_in[0];
        prev_start = inp.ui_in[2];
        prev_read  = inp.ui_in[1];
      end
    end
  endtask

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    if (match_count == 0 && mismatch_count == 0)
      `uvm_error("SCOREBOARD", "No result was ever compared - check start/done/read timing")
    `uvm_info("SCOREBOARD", $sformatf("Scoreboard summary Matches=%0d Mismatches=%0d", match_count, mismatch_count), UVM_NONE)
  endfunction

endclass
