`default_nettype none

module top
(
  input  logic        clk_i,
  input  logic        rst_ni,

  output logic        br_misses,
  output logic        br_instr,
  output logic [31:0] instr


);
`ifdef ALWAYS_TAKEN
  pipelined_always_taken pipelined_always_taken_inst (
    .clk_i  (clk_i),
    .rst_ni (rst_ni),

    .io_sw_i    (),  // Input for switches
    .io_btn_i   (),  // Input for buttons

    .pc_debug_o (),  // Debug program counter
    .insn_vld_o (),  // Instruction valid
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

  assign br_misses = (pipelined_always_taken_inst.IF_flush && pipelined_always_taken_inst.EXMEM_is_jmp);
  assign br_instr  = pipelined_always_taken_inst.EXMEM_is_jmp;
  assign instr     = pipelined_always_taken_inst.IF_instr;
`endif // ALWAYS_TAKEN

`ifdef TWO_BIT
  pipelined_two_bit pipelined_two_bit_inst (
    .clk_i  (clk_i),
    .rst_ni (rst_ni),
    
    .io_sw_i    (),  // Input for switches
    .io_btn_i   (),  // Input for buttons

    .pc_debug_o (),  // Debug program counter
    .insn_vld_o (),  // Instruction valid
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

  assign br_misses = (pipelined_two_bit_inst.IF_flush && pipelined_two_bit_inst.EXMEM_is_jmp);
  assign br_instr  = pipelined_two_bit_inst.EXMEM_is_jmp;
  assign instr     = pipelined_two_bit_inst.IF_instr;
`endif // TWO_BIT

`ifdef GSHARE
  pipelined_gshare pipelined_gshare_inst (
    .clk_i  (clk_i),
    .rst_ni (rst_ni),
    
    .io_sw_i    (),  // Input for switches
    .io_btn_i   (),  // Input for buttons

    .pc_debug_o (),  // Debug program counter
    .insn_vld_o (),  // Instruction valid
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

  assign br_misses = pipelined_gshare_inst.IF_flush;
  assign br_instr  = pipelined_gshare_inst.EXMEM_is_jmp;
  assign instr     = pipelined_gshare_inst.IF_instr;
`endif

`ifdef GSHAREv2
  pipelined_gshare_v2 pipelined_gshare_v2_inst (
    .clk_i  (clk_i),
    .rst_ni (rst_ni),
    
    .io_sw_i    (),  // Input for switches
    .io_btn_i   (),  // Input for buttons

    .pc_debug_o (),  // Debug program counter
    .insn_vld_o (),  // Instruction valid
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

  assign br_misses = pipelined_gshare_v2_inst.IF_flush;
  assign br_instr  = pipelined_gshare_v2_inst.EXMEM_is_jmp;
  assign instr     = pipelined_gshare_v2_inst.IF_instr;
`endif

`ifdef AGREE
  pipelined_agree pipelined_agree_inst (
    .clk_i  (clk_i),
    .rst_ni (rst_ni),
    
    .io_sw_i    (),  // Input for switches
    .io_btn_i   (),  // Input for buttons

    .pc_debug_o (),  // Debug program counter
    .insn_vld_o (),  // Instruction valid
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

  assign br_misses = pipelined_agree_inst.IF_flush;
  assign br_instr  = pipelined_agree_inst.EXMEM_is_jmp;
  assign instr     = pipelined_agree_inst.IF_instr;
`endif 

endmodule : top
