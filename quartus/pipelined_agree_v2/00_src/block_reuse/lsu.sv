module lsu (
    input  logic        clk_i, rst_ni, lsu_wren_i,
    input  logic [2:0]  funct3_i,
    input  logic [31:0] st_data_i, 
                        lsu_addr_i,

    input  logic [31:0] io_sw_i,
    input  logic [3:0]  io_btn_i,       

    output logic [31:0] ld_data_o,

    output logic [31:0] io_lcd_o,
                        io_ledg_o, 
                        io_ledr_o,
    output logic [6:0]  io_hex0_o, 
                        io_hex1_o,
                        io_hex2_o,
                        io_hex3_o,
                        io_hex4_o,
                        io_hex5_o,
                        io_hex6_o,
                        io_hex7_o
);

    logic [2:0]  cs;
    logic [31:0] ld_temp_data;
    logic [12:0] data_mem_addr;
    logic [4:0]  input_mem_addr;
    logic [5:0]  output_mem_addr;
    logic [31:0] data_mem_out, output_mem_out, input_mem_out;

    logic l_unsigned;
    logic [1:0] s_length;
    logic [1:0] l_length;

    assign s_length   = funct3_i[1:0];
    assign l_length   = funct3_i[1:0];
    assign l_unsigned = funct3_i[2];


    // Declare memory space
    logic [7:0] data_mem[0:8191];
    logic [7:0] input_mem[0:31];
    logic [7:0] output_mem[0:63];

    assign data_mem_addr   = lsu_addr_i[12:0]; 
    assign input_mem_addr  = lsu_addr_i[4:0];
    assign output_mem_addr = lsu_addr_i[5:0];

    // Mapping for output memory
    assign io_ledr_o = {output_mem[6'b00_0000+6'h3], output_mem[6'b00_0000+6'h2], output_mem[6'b00_0000+6'h1], output_mem[6'b00_0000]};
    assign io_ledg_o = {output_mem[6'b01_0000+6'h3], output_mem[6'b01_0000+6'h2], output_mem[6'b01_0000+6'h1], output_mem[6'b01_0000]};

    assign io_hex0_o = output_mem[6'b10_0000][6:0];
    assign io_hex1_o = output_mem[6'b10_0001][6:0];
    assign io_hex2_o = output_mem[6'b10_0010][6:0];
    assign io_hex3_o = output_mem[6'b10_0011][6:0];
    assign io_hex4_o = output_mem[6'b10_0100][6:0];
    assign io_hex5_o = output_mem[6'b10_0101][6:0];
    assign io_hex6_o = output_mem[6'b10_0110][6:0];
    assign io_hex7_o = output_mem[6'b10_0111][6:0];

    assign io_lcd_o  = {output_mem[6'b11_0000+6'h3], output_mem[6'b11_0000+6'h2], output_mem[6'b11_0000+6'h1], output_mem[6'b11_0000]}; 

    // Mapping for input memory
    // assign io_sw_i   = {input_mem[5'b0_0000+5'h3], input_mem[5'b0_0000+5'h2], input_mem[5'b0_0000+5'h1], input_mem[5'b0_0000]};
    // assign io_btn_i  = input_mem[5'b1_0000][3:0];

    // cs combinational logic
    always @(*) begin
        if (lsu_addr_i[15:13] == 3'b001) cs = 3'b001;
        else if (lsu_addr_i[15:6] == 10'b0111_0000_00) cs = 3'b010;
        else if (lsu_addr_i[15:5] == 11'b0111_1000_000) cs = 3'b100;
        else cs = 3'b000; 
    end

    // Load select combinational logic
    always @(*) begin
        case (cs)
            3'b001:  ld_temp_data = data_mem_out;
            3'b010:  ld_temp_data = output_mem_out;
            3'b100:  ld_temp_data = input_mem_out;
            default: ld_temp_data = 32'h0000_0000;
        endcase
    end

    // Length select and sign extend
    always @(*) begin
            case({l_unsigned, l_length})
                3'b100:  ld_data_o = {24'b0, ld_temp_data[7:0]};
                3'b101:  ld_data_o = {16'b0, ld_temp_data[15:0]}; 

                3'b000:  ld_data_o = {{24{ld_temp_data[7]}}, ld_temp_data[7:0]};
                3'b001:  ld_data_o = {{16{ld_temp_data[15]}}, ld_temp_data[15:0]};
                3'b010:  ld_data_o = ld_temp_data; 
                default: ld_data_o = 32'b0011001100110011; //debugging
            endcase
    end

    /////////////////////////////////////////
    // Load-Store for data_mem
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            //for (integer i = 0; i < 8192; i = i+1) data_mem[i] <= 8'h00;
        end else begin
            if (cs[0] & lsu_wren_i) begin
                // Store word 
                if (s_length == 2'b10) {data_mem[data_mem_addr+13'h3], data_mem[data_mem_addr+13'h2], data_mem[data_mem_addr+13'h1], data_mem[data_mem_addr]} <= st_data_i;
                //Store half-word
                else if (s_length == 2'b01) {data_mem[data_mem_addr+13'h1], data_mem[data_mem_addr]} <= st_data_i[15:0];
                //Store byte
                else if (s_length == 2'b00) data_mem[data_mem_addr] <= st_data_i[7:0];
                //Other cases
                else data_mem[data_mem_addr] <= data_mem[data_mem_addr];
            end
        end
    end
    // Output of data_mem
    assign data_mem_out = {data_mem[data_mem_addr+13'h3], data_mem[data_mem_addr+13'h2], data_mem[data_mem_addr+13'h1], data_mem[data_mem_addr]};
    
    
    /////////////////////////////////////////
    // Load-Store for output_mem
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            //for (integer i = 0; i < 64; i = i+1) output_mem[i] <= 8'h00;
        end else begin
            if (cs[1] & lsu_wren_i) begin
                // Store word 
                if (s_length == 2'b10) {output_mem[output_mem_addr+6'h3], output_mem[output_mem_addr+6'h2], output_mem[output_mem_addr+6'h1], output_mem[output_mem_addr]} <= st_data_i;
                //Store half-word
                else if (s_length == 2'b01) {output_mem[output_mem_addr+6'h1], output_mem[output_mem_addr]} <= st_data_i[15:0];
                //Store byte
                else if (s_length == 2'b00) output_mem[output_mem_addr] <= st_data_i[7:0];
                //Other cases
                else output_mem[output_mem_addr] <= output_mem[output_mem_addr];
            end
        end
    end
    // Output of output_mem
    assign output_mem_out = {output_mem[output_mem_addr+6'h3], output_mem[output_mem_addr+6'h2], output_mem[output_mem_addr+6'h1], output_mem[output_mem_addr]};

    ///////////////////////////////////////////
    // Load-Store for input_mem
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            //for (integer i = 0; i < 32; i = i+1) input_mem[i] <= 8'h00;
        end else begin
            {input_mem[5'b0_0000+5'h3], input_mem[5'b0_0000+5'h2], input_mem[5'b0_0000+5'h1], input_mem[5'b0_0000]} <= io_sw_i;
            input_mem[5'b1_0000] <= {4'b0000, io_btn_i};
        end
    end
    // Output of input_mem
    assign input_mem_out = {input_mem[input_mem_addr+5'h3], input_mem[input_mem_addr+5'h2], input_mem[input_mem_addr+5'h1], input_mem[input_mem_addr]};


endmodule
