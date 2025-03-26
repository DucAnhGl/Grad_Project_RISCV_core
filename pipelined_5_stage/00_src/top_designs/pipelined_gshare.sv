module pipelined_gshare (
    input  logic        clk_i,      // Global clock, active on the rising edge
    input  logic        rst_ni,     // Global low active reset
    input  logic [31:0] io_sw_i,    // Input for switches
    input  logic [3:0]  io_btn_i,   // Input for buttons

    output logic [31:0] pc_debug_o, // Debug program counter
    output logic        insn_vld_o, // Instruction valid
    output logic [31:0] io_ledr_o,  // Output for driving red LEDs
//    output logic [31:0] io_ledg_o,  // Output for driving green LEDs
    output logic [6:0]  io_hex0_o,  // Output for driving 7-segment LED display
                        io_hex1_o,  // Output for driving 7-segment LED display
                        io_hex2_o,  // Output for driving 7-segment LED display
                        io_hex3_o,  // Output for driving 7-segment LED display
                        io_hex4_o,  // Output for driving 7-segment LED display
                        io_hex5_o,  // Output for driving 7-segment LED display
//                        io_hex6_o,  // Output for driving 7-segment LED display
//                        io_hex7_o,  // Output for driving 7-segment LED display
    output logic [31:0] io_lcd_o    // Output for driving the LCD register
); 

localparam INDEX_WIDTH = 12;
localparam HISTORY_WIDTH = 3;

/*==============================   IF SIGNALS   ==============================*/
    logic [31:0] IF_pc, IF_pcplus4, IF_instr, IF_pcnext, IF_btb_rd_target;
    logic        IF_btb_hit, IF_flush, IF_prediction;
    logic [1:0]  IF_PCnext_sel;

    logic [(HISTORY_WIDTH-1):0] IF_ghr_data;
/*==============================   ID SIGNALS   ==============================*/
    /* Control signal */
    logic ID_insn_vld, ID_is_br, ID_rd_wren, ID_opa_sel, ID_mem_wren, ID_mem_rden, ID_wb_sel;
    logic [1:0] ID_is_uncbr, ID_opb_sel;
    logic [1:0] ID_alu_ctrl;

    /* Data signal */
    logic [31:0] IFID_instr, IFID_pc, IFID_pcplus4;
    logic [4:0]  IFID_rs1, IFID_rs2, IFID_rd;
    logic [31:0] ID_rs1_data, ID_rs2_data, ID_imm;
    logic [2:0]  IFID_funct3;
    logic [6:0]  IFID_funct7;

    logic        IFID_btb_hit, IFID_prediction;
    logic [(HISTORY_WIDTH-1):0] IFID_ghr_data;

/*==============================   EX SIGNALS   ==============================*/
    /* Control signal */
    logic IDEX_insn_vld, IDEX_is_br, IDEX_rd_wren, IDEX_opa_sel, IDEX_mem_wren, IDEX_mem_rden, IDEX_wb_sel;
    logic [1:0] IDEX_is_uncbr, IDEX_opb_sel;
    logic [1:0] IDEX_alu_ctrl;

    /* Data signal */
    logic [31:0] IDEX_pc, IDEX_pcplus4, IDEX_rs1_data, IDEX_rs2_data, IDEX_imm;
    logic [2:0]  IDEX_funct3;
    logic [6:0]  IDEX_funct7;
    logic [4:0]  IDEX_rd, IDEX_rs1, IDEX_rs2;
    logic        IDEX_btb_hit, IDEX_prediction;
    logic [31:0] EX_alu_data, EX_br_addr;
    logic        EX_true_br_decision;
    logic [31:0] EX_alu_opa, EX_alu_opb, EX_br_base, EX_fwd_rs1_data, EX_fwd_rs2_data; 
    logic [3:0]  EX_alu_op;
    
    logic [(HISTORY_WIDTH-1):0] IDEX_ghr_data;

/*==============================   MEM SIGNALS   ==============================*/
    /* Control signal */
    logic EXMEM_insn_vld, EXMEM_is_br, EXMEM_rd_wren, EXMEM_mem_wren, /*EXMEM_mem_rden,*/ EXMEM_wb_sel;
    logic [1:0] EXMEM_is_uncbr;

    /* Data signal */
    logic [31:0] EXMEM_alu_data, EXMEM_br_addr, EXMEM_rs2_data, EXMEM_pc, EXMEM_pcplus4;
    logic        EXMEM_true_br_decision, EXMEM_btb_hit, EXMEM_prediction;
    logic [2:0]  EXMEM_funct3;
    logic [4:0]  EXMEM_rd;
    logic [31:0] MEM_lsu_rdata;
    logic        EXMEM_is_jmp;

    logic [(HISTORY_WIDTH-1):0] EXMEM_ghr_data;

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
        .addr_i (IF_pc),
        .data_o (IF_instr)
    );

    // Branch predictor
    gshare_predictor #(
        .INDEX_WIDTH   (INDEX_WIDTH),
        .HISTORY_WIDTH (HISTORY_WIDTH)
    ) inst_predictor (
        .clk_i                 (clk_i),                            
        .rst_ni                (rst_ni),                          
        .IF_PC_tag_i           (IF_pc[31:(INDEX_WIDTH+2)]),                      
        .IF_btb_rd_index_i     (IF_pc[(INDEX_WIDTH+1):2]),                
        .EXMEM_btb_wr_index_i  (EXMEM_pc[(INDEX_WIDTH+1):2]),             
        .EXMEM_btb_wr_tag_i    (EXMEM_pc[31:(INDEX_WIDTH+2)]),

        .EXMEM_pht_wr_index_i  (EXMEM_pc[HISTORY_WIDTH+1:2]),
        .IF_pht_rd_index_i     (IF_pc[HISTORY_WIDTH+1:2]),

        .EXMEM_btb_wr_target_i (EXMEM_br_addr),            
        .EXMEM_btb_hit_i       (EXMEM_btb_hit),                  
        .EXMEM_prediction_i    (EXMEM_prediction),
        .EXMEM_br_decision_i   (EXMEM_true_br_decision),              
        .EXMEM_is_jmp_i        (EXMEM_is_br/* || (EXMEM_is_uncbr==2'b10)*/),
        .EXMEM_ghr_data_i      (EXMEM_ghr_data),

        .IF_btb_hit_o          (IF_btb_hit),    
        .IF_prediction_o       (IF_prediction),                 
        .IF_PCnext_sel_o       (IF_PCnext_sel),                  
        .IF_btb_rd_target_o    (IF_btb_rd_target),               
        .IF_flush_o            (IF_flush),
        .IF_ghr_data_o         (IF_ghr_data)         
    );


    //PC reg: async rstn, sync wren
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) IF_pc <= 32'h0000_0000;
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
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            IFID_pc      <= 32'h0000_0000;
            IFID_pcplus4 <= 32'h0000_0000;
            IFID_instr   <= 32'h0000_0000;
            IFID_btb_hit <= 1'b0;
            IFID_prediction <= 1'b0;
            IFID_ghr_data   <= 0;
        end
        else begin
            if (IFIDreg_clr) begin
                IFID_pc      <= 32'h0000_0000;
                IFID_pcplus4 <= 32'h0000_0000;
                IFID_instr   <= 32'h0000_0000;
                IFID_btb_hit <= 1'b0;
                IFID_prediction <= 1'b0;
                IFID_ghr_data   <= 0;
            end else begin
                if (IFIDreg_wren) begin
                    IFID_pc      <= IF_pc;
                    IFID_pcplus4 <= IF_pcplus4;
                    IFID_instr   <= IF_instr;
                    IFID_btb_hit <= IF_btb_hit;
                    IFID_prediction <= IF_prediction;
                    IFID_ghr_data   <= IF_ghr_data;
                end
            end       
        end        
    end

/*==============================   ID STAGE   ==============================*/
assign IFID_rs1   = IFID_instr[19:15];
assign IFID_rs2   = IFID_instr[24:20];
assign IFID_rd    = IFID_instr[11:7];
assign IFID_funct3 = IFID_instr[14:12];
assign IFID_funct7 = IFID_instr[31:25];

ctrl_unit inst_ctrl_unit (
    .instr_i    (IFID_instr),

    .rd_wren_o  (ID_rd_wren),      
    .mem_wren_o (ID_mem_wren),     
    .mem_rden_o (ID_mem_rden),     
    .op_a_sel_o (ID_opa_sel),     
    .op_b_sel_o (ID_opb_sel),     
    .is_br_o    (ID_is_br),        
    .is_uncbr_o (ID_is_uncbr),     
    .wb_sel_o   (ID_wb_sel),       
    .alu_ctrl_o (ID_alu_ctrl)   
);

insn_vld_dec insn_vld_dec_inst (
    .instr_i (IFID_instr),
    .insn_vld_o (ID_insn_vld)
);

regfile inst_regfile (
    .clk_i      (clk_i),     
    .rst_ni     (rst_ni),    
    .rd_wren_i  (MEMWB_rd_wren),   
    .rd_addr_i  (MEMWB_rd),   
    .rs1_addr_i (IFID_rs1),  
    .rs2_addr_i (IFID_rs2),  
    .rd_data_i  (WB_rd_data),   
    .rs1_data_o (ID_rs1_data),  
    .rs2_data_o (ID_rs2_data)   
);

immgen inst_immgen (
    .instruction_i (IFID_instr),
    .immediate_o   (ID_imm)
);

//IDEX pipeline register: async rstn, sync clr
always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            //Control signals
            IDEX_insn_vld <= 1'b0;
            IDEX_is_br    <= 1'b0;
            IDEX_is_uncbr <= 2'b00;
            IDEX_rd_wren  <= 1'b0;
            IDEX_opa_sel  <= 1'b0;
            IDEX_opb_sel  <= 2'b00;
            IDEX_alu_ctrl <= 2'b00;
            IDEX_mem_wren <= 1'b0;
            IDEX_mem_rden <= 1'b0;
            IDEX_wb_sel   <= 1'b0;   

            //Data signals
            IDEX_pc       <= 32'h0000_0000;
            IDEX_pcplus4  <= 32'h0000_0000;
            IDEX_rs1_data <= 32'h0000_0000;
            IDEX_rs2_data <= 32'h0000_0000;
            IDEX_imm      <= 32'h0000_0000;
            IDEX_funct3    <= 3'b000;
            IDEX_funct7   <= 7'b0000000;
            IDEX_rd       <= 5'b0_0000;
            IDEX_rs1      <= 5'b0;
            IDEX_rs2      <= 5'b0;
            IDEX_btb_hit  <= 1'b0;
            IDEX_prediction <= 1'b0;
            IDEX_ghr_data   <= 0;
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
                IDEX_alu_ctrl <= 2'b00;
                IDEX_mem_wren <= 1'b0;
                IDEX_mem_rden <= 1'b0;
                IDEX_wb_sel   <= 1'b0;

                //Data signals
                IDEX_pc       <= 32'h0000_0000;
                IDEX_pcplus4  <= 32'h0000_0000;
                IDEX_rs1_data <= 32'h0000_0000;
                IDEX_rs2_data <= 32'h0000_0000;
                IDEX_imm      <= 32'h0000_0000;
                IDEX_funct3   <= 3'b000;
                IDEX_funct7   <= 7'b0000000;
                IDEX_rd       <= 5'b0_0000;
                IDEX_rs1      <= 5'b0;
                IDEX_rs2      <= 5'b0;
                IDEX_btb_hit  <= 1'b0;
                IDEX_prediction <= 1'b0; 
                IDEX_ghr_data   <= 0;
            end
            else begin
                //Control signals
                IDEX_insn_vld <= ID_insn_vld;
                IDEX_is_br    <= ID_is_br;
                IDEX_is_uncbr <= ID_is_uncbr;
                IDEX_rd_wren  <= ID_rd_wren;
                IDEX_opa_sel  <= ID_opa_sel;
                IDEX_opb_sel  <= ID_opb_sel;
                IDEX_alu_ctrl <= ID_alu_ctrl;
                IDEX_mem_wren <= ID_mem_wren;
                IDEX_mem_rden <= ID_mem_rden;
                IDEX_wb_sel   <= ID_wb_sel;

                //Data signals
                IDEX_pc       <= IFID_pc;
                IDEX_pcplus4  <= IFID_pcplus4;
                IDEX_rs1_data <= ID_rs1_data;
                IDEX_rs2_data <= ID_rs2_data;
                IDEX_imm      <= ID_imm;
                IDEX_funct3   <= IFID_funct3;
                IDEX_funct7   <= IFID_funct7;
                IDEX_rd       <= IFID_rd;
                IDEX_rs1      <= IFID_rs1;
                IDEX_rs2      <= IFID_rs2;
                IDEX_btb_hit  <= IFID_btb_hit;
                IDEX_prediction <= IFID_prediction; 
                IDEX_ghr_data   <= IFID_ghr_data;
                
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
    .operand_a_i (EX_alu_opa),  
    .operand_b_i (EX_alu_opb),  
    .alu_op_i    (EX_alu_op),     
    .alu_data_o  (EX_alu_data)   
);

alu_ctrl alu_ctrl_inst (
    .funct3_i   (IDEX_funct3),
    .funct7_i   (IDEX_funct7),
    .alu_ctrl_i (IDEX_alu_ctrl),
    .alu_op_o   (EX_alu_op)
);

assign EX_br_base = (!IDEX_is_uncbr[0]) ? IDEX_pc : EX_fwd_rs1_data;
assign EX_br_addr = IDEX_imm + EX_br_base;

bru inst_bru (
    .rs1_data_i         (EX_fwd_rs1_data),  
    .rs2_data_i         (EX_fwd_rs2_data),  
    .is_br_i            (IDEX_is_br),     
    .is_uncbr_i         (IDEX_is_uncbr[1]),  
    .funct3_i           (IDEX_funct3),     
    .true_br_decision_o (EX_true_br_decision)   
);

//EXMEM pipeline register: async rstn, sync clr
always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            //Control signals
            EXMEM_insn_vld <= 1'b0;
            EXMEM_is_br    <= 1'b0;
            EXMEM_is_uncbr <= 2'b00;
            EXMEM_rd_wren  <= 1'b0;
            EXMEM_mem_wren <= 1'b0;
            //EXMEM_mem_rden <= 1'b0;
            EXMEM_wb_sel   <= 1'b0;

            //Data signals
            EXMEM_alu_data         <= 32'h0000_0000;
            EXMEM_rs2_data         <= 32'h0000_0000;
            EXMEM_br_addr          <= 32'h0000_0000;
            EXMEM_true_br_decision <= 1'b0;
            EXMEM_funct3           <= 3'b000;
            EXMEM_rd               <= 5'b0_0000;
            EXMEM_btb_hit          <= 1'b0;
            EXMEM_pc               <= 32'h0000_0000;
            EXMEM_pcplus4          <= 32'h0000_0000;
            EXMEM_prediction       <= 1'b0; 
            EXMEM_ghr_data         <= 0;
        end
        else begin
            if (EXMEMreg_clr) begin
                //Control signals
                EXMEM_insn_vld <= 1'b0;
                EXMEM_is_br    <= 1'b0;
                EXMEM_is_uncbr <= 2'b00;
                EXMEM_rd_wren  <= 1'b0;
                EXMEM_mem_wren <= 1'b0;
                //EXMEM_mem_rden <= 1'b0;
                EXMEM_wb_sel   <= 1'b0;

                //Data signals
                EXMEM_alu_data         <= 32'h0000_0000;
                EXMEM_rs2_data         <= 32'h0000_0000;
                EXMEM_br_addr          <= 32'h0000_0000;
                EXMEM_true_br_decision <= 1'b0;
                EXMEM_funct3           <= 3'b000;
                EXMEM_rd               <= 5'b0_0000;
                EXMEM_btb_hit          <= 1'b0;
                EXMEM_pc               <= 32'h0000_0000;
                EXMEM_pcplus4          <= 32'h0000_0000;
                EXMEM_prediction       <= 1'b0;
                EXMEM_ghr_data         <= 0;
            end
            else begin
                //Control signals
                EXMEM_insn_vld <= IDEX_insn_vld;
                EXMEM_is_br    <= IDEX_is_br;
                EXMEM_is_uncbr <= IDEX_is_uncbr;
                EXMEM_rd_wren  <= IDEX_rd_wren;
                EXMEM_mem_wren <= IDEX_mem_wren;
                //EXMEM_mem_rden <= IDEX_mem_rden;
                EXMEM_wb_sel   <= IDEX_wb_sel;

                //Data signals
                EXMEM_alu_data         <= EX_alu_data;
                EXMEM_rs2_data         <= EX_fwd_rs2_data;
                EXMEM_br_addr          <= EX_br_addr;
                EXMEM_true_br_decision <= EX_true_br_decision;
                EXMEM_funct3           <= IDEX_funct3;
                EXMEM_rd               <= IDEX_rd;
                EXMEM_btb_hit          <= IDEX_btb_hit;
                EXMEM_pc               <= IDEX_pc;
                EXMEM_pcplus4          <= IDEX_pcplus4;
                EXMEM_prediction       <= IDEX_prediction;
                EXMEM_ghr_data         <= IDEX_ghr_data;
            end
        end        
end

/*==============================   MEM STAGE   ==============================*/
lsu_v2 inst_lsu (
    .clk_i      (clk_i),      
    .rst_ni     (rst_ni),    
    .lsu_wren_i (EXMEM_mem_wren), 
    //.i_lsu_rden (EXMEM_mem_rden), 
    .funct3_i    (EXMEM_funct3),    
    .st_data_i  (EXMEM_rs2_data),  
    .io_sw_i    (io_sw_i),    
    .io_btn_i   (io_btn_i),     
    .lsu_addr_i (EXMEM_alu_data),

    .ld_data_o  (MEM_lsu_rdata),  
    .io_lcd_o   (io_lcd_o),    
//    .io_ledg_o  (io_ledg_o),    
    .io_ledr_o  (io_ledr_o),    
    .io_hex0_o  (io_hex0_o),    
    .io_hex1_o  (io_hex1_o),    
    .io_hex2_o  (io_hex2_o),    
    .io_hex3_o  (io_hex3_o),    
    .io_hex4_o  (io_hex4_o),    
    .io_hex5_o  (io_hex5_o)    
//    .io_hex6_o  (io_hex6_o),    
//    .io_hex7_o  (io_hex7_o)    
);

assign EXMEM_is_jmp = EXMEM_is_br || (EXMEM_is_uncbr==2'b10);

//MEMWB pipeline register: async rstn
always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
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
assign insn_vld_o = MEMWB_insn_vld;

//PC debug
assign pc_debug_o = MEMWB_pc;

/*==============================      HDU     ==============================*/
hdu inst_hdu (
    .br_flush_i      (IF_flush),
    .IDEX_rd_wren_i  (IDEX_rd_wren),
    .IDEX_mem_rden_i (IDEX_mem_rden),
    .IDEX_rd_i       (IDEX_rd),           
    .IFID_rs1_i      (IFID_rs1),     
    .IFID_rs2_i      (IFID_rs2),     
    .IFID_clear_o    (IFIDreg_clr),   
    .IFID_wren_o     (IFIDreg_wren),    
    .IDEX_clear_o    (IDEXreg_clr),   
    .EXMEM_clear_o   (EXMEMreg_clr),  
    .pc_wren_o       (pc_wren)      
);
/*==============================      FWD UNIT     ==============================*/
fwd_unit fwd_unit_inst (
    .IDEX_rs1_i      (IDEX_rs1),      
    .IDEX_rs2_i      (IDEX_rs2),      
    .EXMEM_rd_i      (EXMEM_rd),      
    .MEMWB_rd_i      (MEMWB_rd),      
    .EXMEM_rd_wren_i (EXMEM_rd_wren), 
    .MEMWB_rd_wren_i (MEMWB_rd_wren), 
    .rs1_sel_o       (rs1_sel),       
    .rs2_sel_o       (rs2_sel)          
);


endmodule
