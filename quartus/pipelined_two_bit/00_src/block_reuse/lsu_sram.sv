module lsu (
    input             i_clk, i_rst_n, i_lsu_wren, i_lsu_rden, i_l_unsigned,
							 i_sram_ack,
    input      [1:0]  i_s_length, 
    input      [2:0]  i_l_length,
    input      [31:0] i_st_data, i_io_sw, i_io_btn, i_lsu_addr,
    output reg [31:0] o_ld_data, o_io_lcd, o_io_ledg, o_io_ledr,
                       
    output reg [6:0]  o_io_hex0, o_io_hex1, o_io_hex2, o_io_hex3,
                      o_io_hex4, o_io_hex5, o_io_hex6, o_io_hex7,
							 
	 output            o_cs0, o_ack,  
							 
	 output    [17:0]  o_sram_addr, 
	 inout     [15:0]  io_sram_dq,
	 input             i_sram_oe_n,
	 output            o_sram_ce_n, o_sram_we_n,
							 o_sram_lb_n, o_sram_ub_o
//	 output            sram_state_q_out,
//	 output            sram_rden_out, sram_wren_out  
);

    reg  [2:0]  cs;
    reg  [31:0] ld_temp_data;
    wire [12:0] data_mem_addr;
    wire [4:0]  input_mem_addr;
    wire [5:0]  output_mem_addr;
    wire [31:0] data_mem_out, output_mem_out, input_mem_out;
	 
	 assign o_cs0 = cs[0];
//	 assign sram_rden_out = cs[0] & i_lsu_wren;
//	 assign sram_wren_out = cs[0] & i_lsu_rden;
/*
	 data_mem data_mem_inst(
		.clock	(i_clk),
		.wren		(cs[0] & i_lsu_wren),
		.address (data_mem_addr[12:2]),
		.data    (i_st_data),
		.q			(data_mem_out)
	 );
*/
	 sram sram_inst (
    .i_ADDR     ({{5{1'b0}}, data_mem_addr[12:2], {2{1'b0}}}),
    .i_WDATA    (i_st_data), 
    .i_BMASK    (4'b1111), 
    .i_WREN     (cs[0] & i_lsu_wren), 
    .i_RDEN     (cs[0] & i_lsu_rden), 
    .o_RDATA    (data_mem_out), 
    .o_ACK      (o_ack),
	 
    .SRAM_ADDR  (o_sram_addr), 
    .SRAM_DQ    (io_sram_dq), 
    .SRAM_CE_N  (o_sram_ce_n), 
    .SRAM_WE_N  (o_sram_we_n), 
    .SRAM_LB_N  (o_sram_lb_n), 
    .SRAM_UB_N  (o_sram_ub_o), 
    .SRAM_OE_N  (i_sram_oe_n), 
	 
    .i_clk      (i_clk), 
    .i_reset    (i_rst_n),
	 //.sram_state_q_out (sram_state_q_out)
);

	 
    // Declare memory space
    //reg [7:0] data_mem[0:8191];
    reg [7:0] input_mem[0:31];
    reg [7:0] output_mem[0:63];

    assign data_mem_addr   = i_lsu_addr[12:0]; 
    assign input_mem_addr  = i_lsu_addr[4:0];
    assign output_mem_addr = i_lsu_addr[5:0];

    // Mapping for output memory
    assign o_io_ledr = {output_mem[6'b00_0000+6'h3], output_mem[6'b00_0000+6'h2], output_mem[6'b00_0000+6'h1], output_mem[6'b00_0000]};
    assign o_io_ledg = {output_mem[6'b01_0000+6'h3], output_mem[6'b01_0000+6'h2], output_mem[6'b01_0000+6'h1], output_mem[6'b01_0000]};

    assign o_io_hex0 = output_mem[6'b10_0000][6:0];
    assign o_io_hex1 = output_mem[6'b10_0001][6:0];
    assign o_io_hex2 = output_mem[6'b10_0010][6:0];
    assign o_io_hex3 = output_mem[6'b10_0011][6:0];
    assign o_io_hex4 = output_mem[6'b10_0100][6:0];
    assign o_io_hex5 = output_mem[6'b10_0101][6:0];
    assign o_io_hex6 = output_mem[6'b10_0110][6:0];
    assign o_io_hex7 = output_mem[6'b10_0111][6:0];

    assign o_io_lcd  = {output_mem[6'b11_0000+6'h3], output_mem[6'b11_0000+6'h2], output_mem[6'b11_0000+6'h1], output_mem[6'b11_0000]}; 

    // Mapping for input memory
    // assign i_io_sw   = {input_mem[5'b0_0000+5'h3], input_mem[5'b0_0000+5'h2], input_mem[5'b0_0000+5'h1], input_mem[5'b0_0000]};
    // assign i_io_btn  = input_mem[5'b1_0000][3:0];

    // cs combinational logic
    always @(*) begin
        if (i_lsu_addr[15:13] == 3'b001) cs = 3'b001;
        else if (i_lsu_addr[15:6] == 10'b0111_0000_00) cs = 3'b010;
        else if (i_lsu_addr[15:5] == 11'b0111_1000_000) cs = 3'b100;
        else cs = 3'b000; 
    end

    // Load select combinational logic
    always @(*) begin
        case (cs)
            3'b001:  ld_temp_data = data_mem_out;
            3'b010:  ld_temp_data = output_mem_out;
            3'b100:  ld_temp_data = input_mem_out;
            default: ld_temp_data = ld_temp_data;
        endcase
    end

    // Length select and sign extend
    always @(*) begin
        if(i_l_unsigned) begin
            case(i_l_length)
                3'b100:  o_ld_data = {24'b0, ld_temp_data[7:0]};
                3'b101:  o_ld_data = {16'b0, ld_temp_data[15:0]}; 
                default: o_ld_data = 32'b1111000011110000; //for debugging
            endcase
        end else begin
            case(i_l_length)
                3'b000:  o_ld_data = {{24{ld_temp_data[7]}}, ld_temp_data[7:0]};
                3'b001:  o_ld_data = {{16{ld_temp_data[15]}}, ld_temp_data[15:0]};
                3'b010:  o_ld_data = ld_temp_data; 
                default: o_ld_data = 32'b0011001100110011; //debugging
            endcase
        end
    end

    /////////////////////////////////////////
    // Load-Store for data_mem
    /*always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            for (integer i = 0; i < 8192; i = i+1) data_mem[i] <= 8'h00;
        end else begin
            if (cs[0] & i_lsu_wren) begin
                // Store word 
                if (i_s_length == 2'b10) {data_mem[data_mem_addr+13'h3], data_mem[data_mem_addr+13'h2], data_mem[data_mem_addr+13'h1], data_mem[data_mem_addr]} <= i_st_data;
                //Store half-word
                else if (i_s_length == 2'b01) {data_mem[data_mem_addr+13'h1], data_mem[data_mem_addr]} <= i_st_data[15:0];
                //Store byte
                else if (i_s_length == 2'b00) data_mem[data_mem_addr] <= i_st_data[7:0]; 
            end
        end
    end*/
    // Output of data_mem
    //assign data_mem_out = {data_mem[data_mem_addr+13'h3], data_mem[data_mem_addr+13'h2], data_mem[data_mem_addr+13'h1], data_mem[data_mem_addr]};
    
    
    /////////////////////////////////////////
    // Load-Store for output_mem
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            for (integer i = 0; i < 64; i = i+1) output_mem[i] <= 8'h00;
        end else begin
            if (cs[1] & i_lsu_wren) begin
                // Store word 
                if (i_s_length == 2'b10) {output_mem[output_mem_addr+6'h3], output_mem[output_mem_addr+6'h2], output_mem[output_mem_addr+6'h1], output_mem[output_mem_addr]} <= i_st_data;
                //Store half-word
                else if (i_s_length == 2'b01) {output_mem[output_mem_addr+6'h1], output_mem[output_mem_addr]} <= i_st_data[15:0];
                //Store byte
                else if (i_s_length == 2'b00) output_mem[output_mem_addr] <= i_st_data[7:0]; 
            end
        end
    end
    // Output of output_mem
    assign output_mem_out = {output_mem[output_mem_addr+6'h3], output_mem[output_mem_addr+6'h2], output_mem[output_mem_addr+6'h1], output_mem[output_mem_addr]};

    ///////////////////////////////////////////
    // Load-Store for input_mem
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            for (integer i = 0; i < 32; i = i+1) input_mem[i] <= 8'h00;
        end else begin
            {input_mem[5'b0_0000+5'h3], input_mem[5'b0_0000+5'h2], input_mem[5'b0_0000+5'h1], input_mem[5'b0_0000]} <= i_io_sw;
            input_mem[5'b1_0000] <= {4'b0, i_io_btn};
        end
    end
    // Output of input_mem
    assign input_mem_out = {input_mem[input_mem_addr+6'h3], input_mem[input_mem_addr+6'h2], input_mem[input_mem_addr+6'h1], input_mem[input_mem_addr]};


endmodule