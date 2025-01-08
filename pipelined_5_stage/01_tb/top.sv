`default_nettype none

module top
(
  input  logic        clk_i,
  input  logic        rst_ni,

  output logic        br_misses,
  output logic        br_instr,
  output logic [31:0] instr


);

  pipelined_always_taken pipelined_always_taken_inst (
    .clk_i  (clk_i),
    .rst_ni (rst_ni),

    .io_sw_i    (),    // Input for switches
    .io_btn_i   (),   // Input for buttons

    .pc_debug_o (), // Debug program counter
    .insn_vld_o (), // Instruction valid
    .io_ledr_o  (),  // Output for driving red LEDs
    .io_ledg_o  (),  // Output for driving green LEDs
    .io_hex0_o  (),  // Output for driving 7-segment LED display
    .io_hex1_o  (),  // Output for driving 7-segment LED display
    .io_hex2_o  (),  // Output for driving 7-segment LED display
    .io_hex3_o  (),  // Output for driving 7-segment LED display
    .io_hex4_o  (),  // Output for driving 7-segment LED display
    .io_hex5_o  (),  // Output for driving 7-segment LED display
    .io_hex6_o  (),  // Output for driving 7-segment LED display
    .io_hex7_o  (),  // Output for driving 7-segment LED display
    .io_lcd_o   () // Output for driving the LCD register
  );

  assign br_misses = pipelined_always_taken_inst.IF_flush;
  assign br_instr  = pipelined_always_taken_inst.EX_is_jmp;
  assign instr     = pipelined_always_taken_inst.IF_Instr;


  // Pipelined_two_bit_predictor Pipelined_two_bit_predictor_inst (
  //   .clk_i (clk_i),
  //   .rst_i (rst_i)
  // );

  // assign br_misses = Pipelined_two_bit_predictor_inst.IF_flush;
  // assign br_instr  = Pipelined_two_bit_predictor_inst.EX_is_jmp;
  // assign instr     = Pipelined_two_bit_predictor_inst.IF_Instr;

  // Pipelined_gshare_predictor Pipelined_gshare_predictor_inst (
  //   .clk_i (clk_i),
  //   .rst_i (rst_i)
  // );

  // assign br_misses = Pipelined_gshare_predictor_inst.IF_flush;
  // assign br_instr  = Pipelined_gshare_predictor_inst.EX_is_jmp;
  // assign instr     = Pipelined_gshare_predictor_inst.IF_Instr;

  // Pipelined_agree_predictor Pipelined_agree_predictor_inst (
  //   .clk_i (clk_i),
  //   .rst_i (rst_i)
  // );

  // assign br_misses = Pipelined_agree_predictor_inst.IF_flush;
  // assign br_instr  = Pipelined_agree_predictor_inst.EX_is_jmp;
  // assign instr     = Pipelined_agree_predictor_inst.IF_Instr;

endmodule : top
