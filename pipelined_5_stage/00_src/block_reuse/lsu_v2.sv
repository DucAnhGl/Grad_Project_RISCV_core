module lsu_v2 (
    input  logic        clk_i,
    input  logic        rst_ni,
    input  logic        lsu_wren_i,

    input  logic [2:0]  funct3_i,
    input  logic [31:0] st_data_i, 
                        lsu_addr_i,

    input  logic [31:0] io_sw_i,
    input  logic [3:0]  io_btn_i,       

    output logic [31:0] ld_data_o,

    output logic [31:0] io_lcd_o, 
                        io_ledr_o,

    output logic [6:0]  io_hex0_o, 
                        io_hex1_o,
                        io_hex2_o,
                        io_hex3_o,
                        io_hex4_o,
                        io_hex5_o
);

//  wire declarations
    logic        ram_0_wren, ram_1_wren, ram_2_wren, ram_3_wren;
    logic [2:0]  cs;
    logic [7:0]  ram_0_rdata, ram_1_rdata, ram_2_rdata, ram_3_rdata,
                 ram_rdata_lbyte_pre_sgn_ext;
    logic [15:0] ram_rdata_lhword_pre_sgn_ext;
    logic [13:0] ram_addr;
    logic [2:0]  input_mem_addr;
    logic [3:0]  output_mem_addr;
    logic [31:0] ram_rdata_lbyte,
                 ram_rdata_lhword,
                 ram_rdata,
                 output_mem_out,
                 input_mem_out;

//  Memory buffers declarations
    logic [7:0] input_mem[0:7];
    logic [7:0] output_mem[0:15];


//  Addresses to pass into memory blocks
    assign ram_addr        = lsu_addr_i[15:2];
    assign input_mem_addr  = lsu_addr_i[2:0];
    assign output_mem_addr = lsu_addr_i[3:0];

/////////////// Mapping for output //////////////////
    assign io_ledr_o = {output_mem[4'h0+4'h3], output_mem[4'h0+4'h2], output_mem[4'h0+4'h1], output_mem[4'h0]};

    assign io_hex0_o = output_mem[4'h4][6:0];
    assign io_hex1_o = output_mem[4'h5][6:0];
    assign io_hex2_o = output_mem[4'h6][6:0];
    assign io_hex3_o = output_mem[4'h7][6:0];
    assign io_hex4_o = output_mem[4'h8][6:0];
    assign io_hex5_o = output_mem[4'h9][6:0];

    assign io_lcd_o  = {output_mem[4'hC+4'h3], output_mem[4'hC+4'h2], output_mem[4'hC+4'h1], output_mem[4'hC]};

/////////////// Address decoder for selection between input, output or data memory //////////////////
    always @(*) begin
        case (lsu_addr_i[17:16])
            2'b00  : cs = 3'b000; // Select nothing
            2'b01  : cs = 3'b001; // Select Data-mem
            2'b10  : cs = 3'b010; // Select Output-mem
            2'b11  : cs = 3'b100; // Select Input-mem
            default: cs = 3'b000; // Select nothing
        endcase
    end

/////////////// Write_enable Decoder for selecting blocks of RAM to write to //////////////////
    always @(*) begin
        if (!(lsu_wren_i & cs[0])) begin                                        // Chip select for Data-mem RAMs=0 or lsu_wren=0
            {ram_3_wren, ram_2_wren, ram_1_wren, ram_0_wren} = 4'b0000;         // No wren for all RAM blocks
        end else begin
            case (funct3_i[1:0])
                2'b00: begin // Store byte
                    case (lsu_addr_i[1:0])
                        2'b00  : {ram_3_wren, ram_2_wren, ram_1_wren, ram_0_wren} = 4'b0001; // Store byte [7:0]
                        2'b01  : {ram_3_wren, ram_2_wren, ram_1_wren, ram_0_wren} = 4'b0010; // Store byte [15:8]
                        2'b10  : {ram_3_wren, ram_2_wren, ram_1_wren, ram_0_wren} = 4'b0100; // Store byte [23:16]
                        2'b11  : {ram_3_wren, ram_2_wren, ram_1_wren, ram_0_wren} = 4'b1000; // Store byte [31:24]
                        default: {ram_3_wren, ram_2_wren, ram_1_wren, ram_0_wren} = 4'b0000;
                    endcase
                end
                2'b01: begin // Store half-word
                    case (lsu_addr_i[1:0])
                        2'b00, 2'b01 : {ram_3_wren, ram_2_wren, ram_1_wren, ram_0_wren} = 4'b0011; // Store byte [15:0]
                        2'b10, 2'b11 : {ram_3_wren, ram_2_wren, ram_1_wren, ram_0_wren} = 4'b1100; // Store byte [31:16]
                        default      : {ram_3_wren, ram_2_wren, ram_1_wren, ram_0_wren} = 4'b0000;
                    endcase
                end
                2'b10  : {ram_3_wren, ram_2_wren, ram_1_wren, ram_0_wren} = 4'b1111; // Store word
                default: {ram_3_wren, ram_2_wren, ram_1_wren, ram_0_wren} = 4'b0000;
            endcase
        end
    end

/////////////// RAM data output and sign-extension for load-byte //////////////////
//  Output byte selection mux
    always @(*) begin
        case (lsu_addr_i[1:0])
            2'b00  : ram_rdata_lbyte_pre_sgn_ext = ram_0_rdata;
            2'b01  : ram_rdata_lbyte_pre_sgn_ext = ram_1_rdata;
            2'b10  : ram_rdata_lbyte_pre_sgn_ext = ram_2_rdata;
            2'b11  : ram_rdata_lbyte_pre_sgn_ext = ram_3_rdata;
            default: ram_rdata_lbyte_pre_sgn_ext = ram_0_rdata;
        endcase
    end
//  Sign extension block for data-mem load-byte
    always @(*) begin
        case (funct3_i[2]) // Check for zero-extension or sign-extension
            1'b1: ram_rdata_lbyte = {24'b0, ram_rdata_lbyte_pre_sgn_ext};                                // zero-extension
            1'b0: ram_rdata_lbyte = {{24{ram_rdata_lbyte_pre_sgn_ext[7]}}, ram_rdata_lbyte_pre_sgn_ext}; // sign-extension
        endcase
    end

/////////////// RAM data output and sign-extension for load-half-word //////////////////
//  Output half-word selection mux
    always @(*) begin
        case (lsu_addr_i[1])
            1'b0   : ram_rdata_lhword_pre_sgn_ext = {ram_1_rdata, ram_0_rdata};
            1'b1   : ram_rdata_lhword_pre_sgn_ext = {ram_3_rdata, ram_2_rdata};
            default: ram_rdata_lhword_pre_sgn_ext = {ram_1_rdata, ram_0_rdata};
        endcase
    end
//  Sign extension block for data-mem load-half-word
    always @(*) begin
        case (funct3_i[2]) // Check for zero-extension or sign-extension
            1'b1: ram_rdata_lhword = {16'b0, ram_rdata_lhword_pre_sgn_ext};                                  // zero-extension
            1'b0: ram_rdata_lhword = {{16{ram_rdata_lhword_pre_sgn_ext[15]}}, ram_rdata_lhword_pre_sgn_ext}; // sign-extension
        endcase
    end

/////////////// MUX for selecting output datas of Data-mem: Load-byte, Load_half-word, Load_word //////////////////
    always @(*) begin
        case (funct3_i[1:0])
            2'b00  : ram_rdata = ram_rdata_lbyte;                                      // Load-byte
            2'b01  : ram_rdata = ram_rdata_lhword;                                     // Load-half-word
            2'b10  : ram_rdata = {ram_3_rdata, ram_2_rdata, ram_1_rdata, ram_0_rdata}; // Load-word
            2'b11  : ram_rdata = {ram_3_rdata, ram_2_rdata, ram_1_rdata, ram_0_rdata};
            default: ram_rdata = {ram_3_rdata, ram_2_rdata, ram_1_rdata, ram_0_rdata};
        endcase
    end
/////////////// MUX for selecting output datas of LSU //////////////////
    always @(*) begin
        case (cs)
            3'b001 : ld_data_o = ram_rdata;      // Load from Data-mem
            3'b010 : ld_data_o = output_mem_out; // Load from Output-mem 
            3'b100 : ld_data_o = input_mem_out;  // Load-word Input-mem
            default: ld_data_o = ram_rdata;
        endcase
    end

/////////////// Memory blocks banking //////////////////
//  RAM initialization
    ram8x16k data_ram_0 (
        .clk_i   (clk_i),       
        .wren_i  (ram_0_wren),
        .addr_i  (ram_addr),
        .wdata_i (st_data_i[7:0]),
        .rdata_o (ram_0_rdata)
    );

    ram8x16k data_ram_1 (
        .clk_i   (clk_i),       
        .wren_i  (ram_1_wren),
        .addr_i  (ram_addr),
        .wdata_i (st_data_i[15:8]),
        .rdata_o (ram_1_rdata)
    );

    ram8x16k data_ram_2 (
        .clk_i   (clk_i),       
        .wren_i  (ram_2_wren),
        .addr_i  (ram_addr),
        .wdata_i (st_data_i[23:16]),
        .rdata_o (ram_2_rdata)
    );

    ram8x16k data_ram_3 (
        .clk_i   (clk_i),       
        .wren_i  (ram_3_wren),
        .addr_i  (ram_addr),
        .wdata_i (st_data_i[31:24]),
        .rdata_o (ram_3_rdata)
    );

    initial begin
        $readmemh("../02_sim/dmem/ram0.mem",lsu_v2.data_ram_0.data_mem);
        $readmemh("../02_sim/dmem/ram1.mem",lsu_v2.data_ram_1.data_mem);
        $readmemh("../02_sim/dmem/ram2.mem",lsu_v2.data_ram_2.data_mem);
        $readmemh("../02_sim/dmem/ram3.mem",lsu_v2.data_ram_3.data_mem);
    end

/////////////// Load-store for output buffers //////////////////
//  Store
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            for (integer i = 0; i < 16; i = i+1) output_mem[i] <= 8'h00;
        end else begin
            if (cs[1] & lsu_wren_i) begin
                // Store word 
                if      (funct3_i[1:0] == 2'b10) {output_mem[output_mem_addr+4'h3], output_mem[output_mem_addr+4'h2], output_mem[output_mem_addr+4'h1], output_mem[output_mem_addr]} <= st_data_i;
                //Store half-word
                else if (funct3_i[1:0] == 2'b01) {output_mem[output_mem_addr+4'h1], output_mem[output_mem_addr]} <= st_data_i[15:0];
                //Store byte
                else if (funct3_i[1:0] == 2'b00) output_mem[output_mem_addr] <= st_data_i[7:0];
                //Other cases
                else output_mem[output_mem_addr] <= output_mem[output_mem_addr];
            end
        end
    end
//  Output of output_mem
    always @(*) begin
        case (funct3_i[2])
            1'b1: begin // Load unsigned: zero-extention
                case (funct3_i[1:0])
                    // Load-byte:
                    2'b00  : output_mem_out = {24'b0, output_mem[output_mem_addr]};
                    // Load-half-word:
                    2'b01  : output_mem_out = {16'b0, output_mem[output_mem_addr+4'h1], output_mem[output_mem_addr]};
                    // Load-word:
                    2'b10  : output_mem_out = {output_mem[output_mem_addr+4'h3], output_mem[output_mem_addr+4'h2], output_mem[output_mem_addr+4'h1], output_mem[output_mem_addr]};
                    default: output_mem_out = {24'b0, output_mem[output_mem_addr]};
                endcase
            end
            1'b0: begin // Load signed: sign-extension
                case (funct3_i[1:0])
                    // Load-byte:
                    2'b00   : output_mem_out = {{24{output_mem[output_mem_addr][7]}}, output_mem[output_mem_addr]};
                    // Load-half-word:
                    2'b01   : output_mem_out = {{16{output_mem[output_mem_addr+4'h1][7]}}, output_mem[output_mem_addr+4'h1], output_mem[output_mem_addr]};
                    default : output_mem_out = {{24{output_mem[output_mem_addr][7]}}, output_mem[output_mem_addr]};
                endcase
            end 
            default         : output_mem_out = {24'b0, output_mem[output_mem_addr]};
        endcase
    end

/////////////// Load-store for input buffers //////////////////
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            for (integer i = 0; i < 8; i = i+1) input_mem[i] <= 8'h00;
        end else begin
            {input_mem[3'h0+3'h3], input_mem[3'h0+3'h2], input_mem[3'h0+3'h1], input_mem[3'h0]} <= io_sw_i;
            input_mem[3'h4] <= {4'h4, io_btn_i};
        end
    end

//  Output of input_mem
    always @(*) begin
        case (funct3_i[2])
            1'b1: begin // Load unsigned: zero-extention
                case (funct3_i[1:0])
                    // Load-byte:
                    2'b00  : input_mem_out = {24'b0, input_mem[input_mem_addr]};
                    // Load-half-word:
                    2'b01  : input_mem_out = {16'b0, input_mem[input_mem_addr+3'h1], input_mem[input_mem_addr]};
                    // Load-word:
                    2'b10  : input_mem_out = {input_mem[input_mem_addr+3'h3], input_mem[input_mem_addr+3'h2], input_mem[input_mem_addr+3'h1], input_mem[input_mem_addr]};
                    default: input_mem_out = {24'b0, input_mem[input_mem_addr]};
                endcase
            end
            1'b0: begin // Load signed: sign-extension
                case (funct3_i[1:0])
                    // Load-byte:
                    2'b00   : input_mem_out = {{24{input_mem[input_mem_addr][7]}}, input_mem[input_mem_addr]};
                    // Load-half-word:
                    2'b01   : input_mem_out = {{16{input_mem[input_mem_addr+3'h1][7]}}, input_mem[input_mem_addr+3'h1], input_mem[input_mem_addr]};
                    default : input_mem_out = {{24{input_mem[input_mem_addr][7]}}, input_mem[input_mem_addr]};
                endcase
            end 
            default         : input_mem_out = {24'b0, input_mem[input_mem_addr]};
        endcase
    end

endmodule

