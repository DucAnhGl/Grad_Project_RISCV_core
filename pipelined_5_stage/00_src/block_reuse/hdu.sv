module hdu (
    input  logic       IDEX_rdwren_i,
    input  logic       IDEX_mem_rden_i,
    input  logic       br_flush_i,

    input  logic [4:0] IDEX_rd_i,
    input  logic [4:0] IFID_rs1_i,
    input  logic [4:0] IFID_rs2_i,

    output logic       IFID_clear_o,
    output logic       IDEX_clear_o,
    output logic       EXMEM_clear_o,
    output logic       IFID_wren_o,
    output logic       pc_wren_o
);
    always @(*) begin
        if (br_flush_i) begin
            IFID_clear_o  = 1'b1;
            IDEX_clear_o  = 1'b1;
            EXMEM_clear_o = 1'b1;
            pc_wren_o     = 1'b1;
            IFID_wren_o   = 1'b1;           
        end else if ((IDEX_mem_rden_i && (IDEX_rd_i != 5'b00_000) && IDEX_rd_wren_i && (IDEX_rd_i == IFID_rs1_i || IDEX_rd_i == IFID_rs2_i))) begin
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
