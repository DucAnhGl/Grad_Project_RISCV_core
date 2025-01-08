module two_bit (
    input  logic        i_clk,      // Global clock, active on the rising edge
    input  logic        i_rstn,     // Global low active reset
    input  logic [31:0] i_io_sw,    // Input for switches
    input  logic [3:0]  i_io_btn,   // Input for buttons
    output logic [31:0] o_pc_debug, // Debug program counter
    output logic        o_insn_vld, // Instruction valid
    output logic [31:0] o_io_ledr,  // Output for driving red LEDs
    output logic [31:0] o_io_ledg,  // Output for driving green LEDs
    output logic [6:0]  o_io_hex0, o_io_hex1, o_io_hex2, o_io_hex3, o_io_hex4, o_io_hex5, o_io_hex6, o_io_hex7,   // Output for driving 7-segment LED displays
    output logic [31:0] o_io_lcd    // Output for driving the LCD register
	 
	 // output to SRAM
	//  input  logic        i_sram_oe_n,
	//  output logic [17:0] o_sram_addr,
	//  inout  wire  [15:0] io_sram_dq,
	//  output logic        o_sram_ce_n, o_sram_we_n,
	// 					 o_sram_lb_n, o_sram_ub_o
); 

localparam INDEX_WIDTH = 12;

/*==============================   IF SIGNALS   ==============================*/
    logic [31:0] IF_pc, IF_pcplus4, IF_instr, IF_pcnext, IF_btb_rd_target;
    logic        IF_btb_hit, IF_flush, IF_prediction;
    logic [1:0]  IF_PCnext_sel;

/*==============================   ID SIGNALS   ==============================*/
    /* Control signal */
    logic ID_insn_vld, ID_is_br, ID_rd_wren, ID_opa_sel, ID_mem_wren, ID_mem_rden, ID_wb_sel;
    logic [1:0] ID_is_uncbr, ID_opb_sel;
    logic [3:0] ID_alu_op;

    /* Data signal */
    logic [31:0] IFID_instr, IFID_pc, IFID_pcplus4;
    logic [4:0]  IFID_rs1, IFID_rs2, IFID_rd;
    logic [31:0] ID_rs1_data, ID_rs2_data, ID_imm;
    logic [2:0]  IFID_func3;
    logic        IFID_btb_hit, IFID_prediction;

/*==============================   EX SIGNALS   ==============================*/
    /* Control signal */
    logic IDEX_insn_vld, IDEX_is_br, IDEX_rd_wren, IDEX_opa_sel, IDEX_mem_wren, IDEX_mem_rden, IDEX_wb_sel;
    logic [1:0] IDEX_is_uncbr, IDEX_opb_sel;
    logic [3:0] IDEX_alu_op;

    /* Data signal */
    logic [31:0] IDEX_pc, IDEX_pcplus4, IDEX_rs1_data, IDEX_rs2_data, IDEX_imm;
    logic [2:0]  IDEX_func3;
    logic [4:0]  IDEX_rd, IDEX_rs1, IDEX_rs2;
    logic        IDEX_btb_hit, IDEX_prediction;
    logic [31:0] EX_alu_data, EX_br_addr;
    logic        EX_pcsel;
    logic [31:0] EX_alu_opa, EX_alu_opb, EX_br_base, EX_fwd_rs1_data, EX_fwd_rs2_data; 
 
/*==============================   MEM SIGNALS   ==============================*/
    /* Control signal */
    logic EXMEM_insn_vld, EXMEM_is_br, EXMEM_rd_wren, EXMEM_mem_wren, EXMEM_mem_rden, EXMEM_wb_sel;
    logic [1:0] EXMEM_is_uncbr;

    /* Data signal */
    logic [31:0] EXMEM_alu_data, EXMEM_br_addr, EXMEM_rs2_data, EXMEM_pc, EXMEM_pcplus4;
    logic        EXMEM_pcsel, EXMEM_btb_hit, EXMEM_prediction;
    logic [2:0]  EXMEM_func3;
    logic [4:0]  EXMEM_rd;
    logic [31:0] MEM_lsu_rdata;

/*==============================   WB SIGNALS   ==============================*/
    /* Control signal */
    logic MEMWB_insn_vld, MEMWB_rd_wren, MEMWB_wb_sel;

    /* Data signal */
    logic [31:0] MEMWB_lsu_rdata, MEMWB_alu_data;
    logic [4:0]  MEMWB_rd;
    logic [31:0] WB_rd_data;

    /*PC debug*/
    logic [31:0] MEMWB_pc;

/*==============================   HDU SIGNALS   ==============================*/
    logic pc_wren, IFIDreg_clr, IFIDreg_wren, IDEXreg_clr, EXMEMreg_clr;

/*==============================   FWD UNIT SIGNALS   ==============================*/
    logic [1:0] rs1_sel, rs2_sel;

/*================================================================================================================*/
                                                /*CONNECTIONS*/
/*================================================================================================================*/

/*==============================   IF STAGE   ==============================*/
    // Instruction mem
    imem inst_imem(
        .i_addr(IF_pc),
        .o_data(IF_instr)
    );

    // Branch predictor
    two_bit_predictor #(
        .INDEX_WIDTH(INDEX_WIDTH)
    ) inst_predictor (
        .clk_i                 (i_clk),                            
        .rst_i                 (i_rstn),                            
        .IF_PC_tag_i           (IF_pc[31:(INDEX_WIDTH+2)]),                      
        .IF_btb_rd_index_i     (IF_pc[(INDEX_WIDTH+1):2]),                
        .EXMEM_btb_wr_index_i  (EXMEM_pc[(INDEX_WIDTH+1):2]),             
        .EXMEM_btb_wr_tag_i    (EXMEM_pc[31:(INDEX_WIDTH+2)]),               
        .EXMEM_btb_wr_target_i (EXMEM_br_addr),            
        .EXMEM_btb_hit_i       (EXMEM_btb_hit),                  
        .EXMEM_br_decision_i   (EXMEM_pcsel),  
        .EXMEM_prediction_i    (EXMEM_prediction),
        //.EXMEM_is_jmp_i        (EXMEM_is_br || (EXMEM_is_uncbr==2'b10)),
        .EXMEM_is_br_i         (EXMEM_is_br),
        .EXMEM_is_uncbr_i      (EXMEM_is_uncbr),                   
        .IF_btb_hit_o          (IF_btb_hit),    
        .IF_prediction_o       (IF_prediction),                 
        .IF_PCnext_sel_o       (IF_PCnext_sel),                  
        .IF_btb_rd_target_o    (IF_btb_rd_target),               
        .IF_flush_o            (IF_flush)                        
    );


    //PC reg: async rstn, sync wren
    always @(posedge i_clk or negedge i_rstn) begin
        if (!i_rstn) IF_pc <= 32'h0000_0000;
        else begin
            if (pc_wren) IF_pc <= IF_pcnext;
            else IF_pc <= IF_pc; 
        end
    end

    //PC plus 4 adder
    assign IF_pcplus4 = IF_pc + 32'h4;

    //next PC select mux
    assign IF_pcnext = (IF_PCnext_sel == 2'b00) ? IF_pcplus4 :
                       (IF_PCnext_sel == 2'b01) ? EXMEM_pcplus4 :
                       (IF_PCnext_sel == 2'b10) ? IF_btb_rd_target : EXMEM_br_addr;

    // IFID pipeline register:
    always @(posedge i_clk or negedge i_rstn) begin
        if (!i_rstn) begin
            IFID_pc         <= 32'h0000_0000;
            IFID_pcplus4    <= 32'h0000_0000;
            IFID_instr      <= 32'h0000_0000;
            IFID_btb_hit    <= 1'b0;
            IFID_prediction <= 1'b0;
        end
        else begin
            if (IFIDreg_clr) begin
                IFID_pc         <= 32'h0000_0000;
                IFID_pcplus4    <= 32'h0000_0000;
                IFID_instr      <= 32'h0000_0000;
                IFID_btb_hit    <= 1'b0;
                IFID_prediction <= 1'b0;
            end else begin
                if (IFIDreg_wren) begin
                    IFID_pc         <= IF_pc;
                    IFID_pcplus4    <= IF_pcplus4;
                    IFID_instr      <= IF_instr;
                    IFID_btb_hit    <= IF_btb_hit;
                    IFID_prediction <= IF_prediction;
                end
            end       
        end        
    end

/*==============================   ID STAGE   ==============================*/
assign IFID_rs1   = IFID_instr[19:15];
assign IFID_rs2   = IFID_instr[24:20];
assign IFID_rd    = IFID_instr[11:7];
assign IFID_func3 = IFID_instr[14:12];

ctrl_unit inst_ctrl_unit (
    .instr    (IFID_instr),

    .rd_wren  (ID_rd_wren),      
    .mem_wren (ID_mem_wren),     
    .mem_rden (ID_mem_rden),     
    .op_a_sel (ID_opa_sel),     
    .op_b_sel (ID_opb_sel),     
    .is_br    (ID_is_br),        
    .is_uncbr (ID_is_uncbr),     
    .wb_sel   (ID_wb_sel),       
    .alu_op   (ID_alu_op),        
    .insn_vld (ID_insn_vld)     
);

regfile inst_regfile (
    .clk_i    (i_clk),     
    .rd_wren  (MEMWB_rd_wren),   
    .rst_ni   (i_rstn),    
    .rd_addr  (MEMWB_rd),   
    .rs1_addr (IFID_rs1),  
    .rs2_addr (IFID_rs2),  
    .rd_data  (WB_rd_data),   
    .rs1_data (ID_rs1_data),  
    .rs2_data (ID_rs2_data)   
);

immgen inst_immgen (
    .instruction_i (IFID_instr),
    .immediate_o   (ID_imm)
);

//IDEX pipeline register: async rstn, sync clr
always @(posedge i_clk or negedge i_rstn) begin
        if (!i_rstn) begin
            //Control signals
            IDEX_insn_vld   <= 1'b0;
            IDEX_is_br      <= 1'b0;
            IDEX_is_uncbr   <= 2'b00;
            IDEX_rd_wren    <= 1'b0;
            IDEX_opa_sel    <= 1'b0;
            IDEX_opb_sel    <= 2'b00;
            IDEX_alu_op     <= 4'b0000;
            IDEX_mem_wren   <= 1'b0;
            IDEX_mem_rden   <= 1'b0;
            IDEX_wb_sel     <= 1'b0;  

            //Data signals
            IDEX_pc         <= 32'h0000_0000;
            IDEX_pcplus4    <= 32'h0000_0000;
            IDEX_rs1_data   <= 32'h0000_0000;
            IDEX_rs2_data   <= 32'h0000_0000;
            IDEX_imm        <= 32'h0000_0000;
            IDEX_func3      <= 3'b000;
            IDEX_rd         <= 5'b0_0000;
            IDEX_rs1        <= 5'b0;
            IDEX_rs2        <= 5'b0;
            IDEX_btb_hit    <= 1'b0;
            IDEX_prediction <= 1'b0;
        end
        else begin
            if (IDEXreg_clr) begin
                //Control signals
                IDEX_insn_vld <= 1'b0;
                IDEX_is_br    <= 1'b0;
                IDEX_is_uncbr <= 2'b00;
                IDEX_rd_wren  <= 1'b0;
                IDEX_opa_sel  <= 1'b0;
                IDEX_opb_sel  <= 2'b00;
                IDEX_alu_op   <= 4'b0000;
                IDEX_mem_wren <= 1'b0;
                IDEX_mem_rden <= 1'b0;
                IDEX_wb_sel   <= 1'b0;

                //Data signals
                IDEX_pc         <= 32'h0000_0000;
                IDEX_pcplus4    <= 32'h0000_0000;
                IDEX_rs1_data   <= 32'h0000_0000;
                IDEX_rs2_data   <= 32'h0000_0000;
                IDEX_imm        <= 32'h0000_0000;
                IDEX_func3      <= 3'b000;
                IDEX_rd         <= 5'b0_0000;
                IDEX_rs1        <= 5'b0;
                IDEX_rs2        <= 5'b0;
                IDEX_btb_hit    <= 1'b0;
                IDEX_prediction <= 1'b0; 
            end
            else begin
                //Control signals
                IDEX_insn_vld <= ID_insn_vld;
                IDEX_is_br    <= ID_is_br;
                IDEX_is_uncbr <= ID_is_uncbr;
                IDEX_rd_wren  <= ID_rd_wren;
                IDEX_opa_sel  <= ID_opa_sel;
                IDEX_opb_sel  <= ID_opb_sel;
                IDEX_alu_op   <= ID_alu_op;
                IDEX_mem_wren <= ID_mem_wren;
                IDEX_mem_rden <= ID_mem_rden;
                IDEX_wb_sel   <= ID_wb_sel;

                //Data signals
                IDEX_pc         <= IFID_pc;
                IDEX_pcplus4    <= IFID_pcplus4;
                IDEX_rs1_data   <= ID_rs1_data;
                IDEX_rs2_data   <= ID_rs2_data;
                IDEX_imm        <= ID_imm;
                IDEX_func3      <= IFID_func3;
                IDEX_rd         <= IFID_rd;
                IDEX_rs1        <= IFID_rs1;
                IDEX_rs2        <= IFID_rs2;
                IDEX_btb_hit    <= IFID_btb_hit;
                IDEX_prediction <= IFID_prediction; 
                
            end
        end        
    end

/*==============================   EX STAGE   ==============================*/
assign EX_fwd_rs1_data = (rs1_sel == 2'b00) ? IDEX_rs1_data  :
                         (rs1_sel == 2'b01) ? EXMEM_alu_data : WB_rd_data;
assign EX_fwd_rs2_data = (rs2_sel == 2'b00) ? IDEX_rs2_data  :
                         (rs2_sel == 2'b01) ? EXMEM_alu_data : WB_rd_data;


assign EX_alu_opa = (!IDEX_opa_sel) ? EX_fwd_rs1_data : IDEX_pc;
assign EX_alu_opb = (IDEX_opb_sel == 2'b00) ? EX_fwd_rs2_data :
                    (IDEX_opb_sel == 2'b01) ? IDEX_imm : IDEX_pcplus4;

alu inst_alu (
    .i_operand_a (EX_alu_opa),  
    .i_operand_b (EX_alu_opb),  
    .i_alu_op    (IDEX_alu_op),     
    .o_alu_data  (EX_alu_data)    
);

assign EX_br_base = (!IDEX_is_uncbr[0]) ? IDEX_pc : EX_fwd_rs1_data;
assign EX_br_addr = IDEX_imm + EX_br_base;

bru inst_bru (
    .rs1_data (EX_fwd_rs1_data),  
    .rs2_data (EX_fwd_rs2_data),  
    .is_br    (IDEX_is_br),     
    .is_uncbr (IDEX_is_uncbr[1]),  
    .func3    (IDEX_func3),     
    .pc_sel   (EX_pcsel)     
);

//EXMEM pipeline register: async rstn, sync clr
always @(posedge i_clk or negedge i_rstn) begin
        if (!i_rstn) begin
            //Control signals
            EXMEM_insn_vld <= 1'b0;
            EXMEM_is_br    <= 1'b0;
            EXMEM_is_uncbr <= 2'b00;
            EXMEM_rd_wren  <= 1'b0;
            EXMEM_mem_wren <= 1'b0;
            EXMEM_mem_rden <= 1'b0;
            EXMEM_wb_sel   <= 1'b0;

            //Data signals
            EXMEM_alu_data   <= 32'h0000_0000;
            EXMEM_rs2_data   <= 32'h0000_0000;
            EXMEM_br_addr    <= 32'h0000_0000;
            EXMEM_pcsel      <= 1'b0;
            EXMEM_func3      <= 3'b000;
            EXMEM_rd         <= 5'b0_0000;
            EXMEM_btb_hit    <= 1'b0;
            EXMEM_prediction <= 1'b0; 
            EXMEM_pc         <= 32'h0000_0000;
            EXMEM_pcplus4    <= 32'h0000_0000;
        end
        else begin
            if (EXMEMreg_clr) begin
                //Control signals
                EXMEM_insn_vld <= 1'b0;
                EXMEM_is_br    <= 1'b0;
                EXMEM_is_uncbr <= 2'b00;
                EXMEM_rd_wren  <= 1'b0;
                EXMEM_mem_wren <= 1'b0;
                EXMEM_mem_rden <= 1'b0;
                EXMEM_wb_sel   <= 1'b0;

                //Data signals
                EXMEM_alu_data   <= 32'h0000_0000;
                EXMEM_rs2_data   <= 32'h0000_0000;
                EXMEM_br_addr    <= 32'h0000_0000;
                EXMEM_pcsel      <= 1'b0;
                EXMEM_func3      <= 3'b000;
                EXMEM_rd         <= 5'b0_0000;
                EXMEM_btb_hit    <= 1'b0;
                EXMEM_prediction <= 1'b0;
                EXMEM_pc         <= 32'h0000_0000;
                EXMEM_pcplus4    <= 32'h0000_0000;
            end
            else begin
                //Control signals
                EXMEM_insn_vld <= IDEX_insn_vld;
                EXMEM_is_br    <= IDEX_is_br;
                EXMEM_is_uncbr <= IDEX_is_uncbr;
                EXMEM_rd_wren  <= IDEX_rd_wren;
                EXMEM_mem_wren <= IDEX_mem_wren;
                EXMEM_mem_rden <= IDEX_mem_rden;
                EXMEM_wb_sel   <= IDEX_wb_sel;

                //Data signals
                EXMEM_alu_data   <= EX_alu_data;
                EXMEM_rs2_data   <= EX_fwd_rs2_data;
                EXMEM_br_addr    <= EX_br_addr;
                EXMEM_pcsel      <= EX_pcsel;
                EXMEM_func3      <= IDEX_func3;
                EXMEM_rd         <= IDEX_rd;
                EXMEM_btb_hit    <= IDEX_btb_hit;
                EXMEM_prediction <= IDEX_prediction;
                EXMEM_pc         <= IDEX_pc;
                EXMEM_pcplus4    <= IDEX_pcplus4;
            end
        end        
end

/*==============================   MEM STAGE   ==============================*/
lsu inst_lsu (
    .i_clk      (i_clk),      
    .i_rst_n    (i_rstn),    
    .i_lsu_wren (EXMEM_mem_wren), 
    //.i_lsu_rden (EXMEM_mem_rden), 
    .i_func3    (EXMEM_func3),    
    .i_st_data  (EXMEM_rs2_data),  
    .i_io_sw    (i_io_sw),    
    .i_io_btn   (i_io_btn),     
    .i_lsu_addr (EXMEM_alu_data), 
    .o_ld_data  (MEM_lsu_rdata),  
    .o_io_lcd   (o_io_lcd),    
    .o_io_ledg  (o_io_ledg),    
    .o_io_ledr  (o_io_ledr),    
    .o_io_hex0  (o_io_hex0),    
    .o_io_hex1  (o_io_hex1),    
    .o_io_hex2  (o_io_hex2),    
    .o_io_hex3  (o_io_hex3),    
    .o_io_hex4  (o_io_hex4),    
    .o_io_hex5  (o_io_hex5),    
    .o_io_hex6  (o_io_hex6),    
    .o_io_hex7  (o_io_hex7)      
);

//MEMWB pipeline register: async rstn
always @(posedge i_clk or negedge i_rstn) begin
        if (!i_rstn) begin
            //Control signals
            MEMWB_insn_vld <= 1'b0;
            MEMWB_rd_wren  <= 1'b0;
            MEMWB_wb_sel   <= 1'b0;

            //Data signals
            MEMWB_alu_data  <= 32'h0000_0000;
            MEMWB_lsu_rdata <= 32'h0000_0000;
            MEMWB_rd        <= 5'b0_0000;

            //PC debug
            MEMWB_pc        <= 32'h0000_0000;
        end
        else begin
            //Control signals
            MEMWB_insn_vld <= EXMEM_insn_vld;
            MEMWB_rd_wren  <= EXMEM_rd_wren;
            MEMWB_wb_sel   <= EXMEM_wb_sel;

            //Data signals
            MEMWB_alu_data  <= EXMEM_alu_data;
            MEMWB_lsu_rdata <= MEM_lsu_rdata;
            MEMWB_rd        <= EXMEM_rd;

            //PC debug
            MEMWB_pc        <= EXMEM_pc;
        end
end

/*==============================   WB STAGE   ==============================*/
assign WB_rd_data = (!MEMWB_wb_sel) ? MEMWB_alu_data : MEMWB_lsu_rdata;
assign o_insn_vld = MEMWB_insn_vld;

//PC debug
assign o_pc_debug = MEMWB_pc;

/*==============================      HDU     ==============================*/
hdu inst_hdu (
    .br_flush       (IF_flush),
    .IDEX_rdwren    (IDEX_rd_wren),
    .IDEX_mem_rden  (IDEX_mem_rden),
    .IDEX_rd        (IDEX_rd),           
    .IFID_rs1       (IFID_rs1),     
    .IFID_rs2       (IFID_rs2),     
    .IFID_clear     (IFIDreg_clr),   
    .IFID_wren      (IFIDreg_wren),    
    .IDEX_clear     (IDEXreg_clr),   
    .EXMEM_clear    (EXMEMreg_clr),  
    .pc_wren        (pc_wren)       
);
/*==============================      FWD UNIT     ==============================*/
fwd_unit fwd_unit_inst (
    .IDEX_rs1       (IDEX_rs1),      
    .IDEX_rs2       (IDEX_rs2),      
    .EXMEM_rd       (EXMEM_rd),      
    .MEMWB_rd       (MEMWB_rd),      
    .EXMEM_rd_wren  (EXMEM_rd_wren), 
    .MEMWB_rd_wren  (MEMWB_rd_wren), 
    .rs1_sel        (rs1_sel),       
    .rs2_sel        (rs2_sel)          
);


endmodule
