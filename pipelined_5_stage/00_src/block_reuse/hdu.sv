module hdu (
    input  logic IDEX_rdwren, IDEX_mem_rden, br_flush,   
    input  logic [4:0] IDEX_rd, IFID_rs1, IFID_rs2,

    output logic IFID_clear, IDEX_clear,
                 EXMEM_clear, IFID_wren, pc_wren  
);
    always @(*) begin
        if(br_flush) begin
            IFID_clear  = 1'b1;
            IDEX_clear  = 1'b1;
            EXMEM_clear = 1'b1;
            pc_wren     = 1'b1;
            IFID_wren   = 1'b1;           
        end else if((IDEX_mem_rden && (IDEX_rd != 5'b00_000) && IDEX_rdwren && (IDEX_rd == IFID_rs1 || IDEX_rd == IFID_rs2))) begin
                        pc_wren    = 1'b0;
                        IFID_wren  = 1'b0;
                        IDEX_clear = 1'b1;
                        EXMEM_clear = 1'b0;
                        IFID_clear  = 1'b0;
        end else begin
            IFID_clear  = 1'b0;
            IDEX_clear  = 1'b0;
            EXMEM_clear = 1'b0;
            pc_wren     = 1'b1;
            IFID_wren   = 1'b1;           
        end
    end

endmodule
