module hdu (
    input  logic       IDEX_rdwren_i, IDEX_mem_rden_i, br_flush_i,   
    input  logic [4:0] IDEX_rd_i,
    input  logic [4:0] IFID_rs1_i, IFID_rs2_i,

    output logic       IFID_clear_o, IDEX_clear_o, EXMEM_clear_o, 
                       IFID_wren_o, pc_wren_o  
);
    always @(*) begin
        if (br_flush_i) begin
            IFID_clear_o  = 1'b1;
            IDEX_clear_o  = 1'b1;
            EXMEM_clear_o = 1'b1;
            pc_wren_o     = 1'b1;
            IFID_wren_o   = 1'b1;           
        end else if ((IDEX_mem_rden_i && (IDEX_rd_i != 5'b00_000) && IDEX_rdwren_i && (IDEX_rd_i == IFID_rs1_i || IDEX_rd_i == IFID_rs2_i))) begin
            IFID_clear_o  = 1'b0;
            IDEX_clear_o  = 1'b1;
            EXMEM_clear_o = 1'b0;
            pc_wren_o     = 1'b0;
            IFID_wren_o   = 1'b0;
        end else begin
            IFID_clear_o  = 1'b0;
            IDEX_clear_o  = 1'b0;
            EXMEM_clear_o = 1'b0;
            pc_wren_o     = 1'b1;
            IFID_wren_o   = 1'b1;           
        end
    end

endmodule
