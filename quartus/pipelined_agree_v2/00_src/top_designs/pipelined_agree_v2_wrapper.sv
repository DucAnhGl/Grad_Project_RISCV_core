module pipelined_agree_v2_wrapper (
    input  logic        CLOCK_50_i, // Global clock, active on the rising edge
    input  logic [9:0]  SW_i,    // Input for switches
    input  logic [3:0]  KEY_i,   // Input for buttons

    output logic [9:0]  LEDR_o,  // Output for driving red LEDs
    output logic [6:0]  HEX0_o,  // Output for driving 7-segment LED display
                        HEX1_o,  // Output for driving 7-segment LED display
                        HEX2_o,  // Output for driving 7-segment LED display
                        HEX3_o,  // Output for driving 7-segment LED display
                        HEX4_o,  // Output for driving 7-segment LED display
                        HEX5_o,  // Output for driving 7-segment LED display
    output logic [12:0] LCD_o    // Output for driving the LCD register
);

	localparam HISTORY_WIDTH = 8;
	
	logic Q1, rst_n_sync;
	
	// Reset synchronizer
	always @(posedge clk_div or negedge SW_i[9]) begin
		if (!SW_i[9]) begin
			Q1 <= 1'b0;
			rst_n_sync <= 1'b0;
		end else begin
			Q1 <= 1'b1;
			rst_n_sync <= Q1;
		end
	end


	pipelined_agree_v2 #(
        .HISTORY_WIDTH(HISTORY_WIDTH)
    ) pipelined_agree_v2_inst (
        .clk_i           (CLOCK_50_i),                
        .rst_ni          (rst_n_sync),               
        .io_sw_i         ({{23{1'b0}},SW_i[8:0]}),        
        .io_btn_i        (KEY_i),       

        .pc_debug_o      (),     
        .insn_vld_o      (),           
        .io_ledr_o[9:0]  (LEDR_o),  
		  .io_ledr_o[31:10](),
        .io_hex0_o       (HEX0_o),
        .io_hex1_o       (HEX1_o),
        .io_hex2_o       (HEX2_o),
        .io_hex3_o       (HEX3_o),
        .io_hex4_o       (HEX4_o),   
        .io_hex5_o       (HEX5_o),
        .io_lcd_o        ({LCD_o[12], LCD_o[11], {19{1'd0}}, LCD_o[10:0]})   
    );


endmodule