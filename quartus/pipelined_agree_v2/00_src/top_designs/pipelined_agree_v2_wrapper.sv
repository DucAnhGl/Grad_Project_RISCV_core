module pipelined_agree_v2_wrapper (
    input  logic        CLOCK_50, // Global clock, active on the rising edge
    input  logic [9:0]  SW,    // Input for switches
    input  logic [3:0]  KEY,   // Input for buttons

    output logic [9:0]  LEDR,  // Output for driving red LEDs
    output logic [6:0]  HEX0,  // Output for driving 7-segment LED display
                        HEX1,  // Output for driving 7-segment LED display
                        HEX2,  // Output for driving 7-segment LED display
                        HEX3,  // Output for driving 7-segment LED display
                        HEX4,  // Output for driving 7-segment LED display
                        HEX5  // Output for driving 7-segment LED display
    //output logic [12:0] LCD    // Output for driving the LCD register
);

	localparam HISTORY_WIDTH = 4;
	
	logic Q1, rst_n_sync;
	logic clk_div, clk_div1;
	
	// Clock divider 1/4
	always@(posedge CLOCK_50 or negedge SW[9]) begin
		if (!SW[9]) begin
			clk_div1 <= 1'b0;
		end
		else 
			clk_div1 <= ~clk_div1;
	end

	always@(posedge clk_div1 or negedge SW[9]) begin
		if (!SW[9]) begin
			clk_div <= 1'b0;
		end
		else 
			clk_div <= ~clk_div;
	end
	
	// Reset synchronizer
	always @(posedge clk_div or negedge SW[9]) begin
		if (!SW[9]) begin
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
        .clk_i           (clk_div),                
        .rst_ni          (rst_n_sync),               
        .io_sw_i         ({{23{1'b0}},SW[8:0]}), 
        .io_btn_i        (KEY),       

        .pc_debug_o      (),     
        .insn_vld_o      (),           
        .io_ledr_o  		 (LEDR),  
        .io_hex0_o       (HEX0),
        .io_hex1_o       (HEX1),
        .io_hex2_o       (HEX2),
        .io_hex3_o       (HEX3),
        .io_hex4_o       (HEX4),   
        .io_hex5_o       (HEX5),
        .io_lcd_o        ()	  
    );


endmodule