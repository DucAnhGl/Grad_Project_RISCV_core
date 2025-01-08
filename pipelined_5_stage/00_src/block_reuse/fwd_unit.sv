module fwd_unit(
    input  logic [4:0] IDEX_rs1, IDEX_rs2, EXMEM_rd, MEMWB_rd,       
    input  logic       EXMEM_rd_wren, MEMWB_rd_wren,  
    output logic [1:0] rs1_sel, rs2_sel
);
always @(*) begin
    if(EXMEM_rd_wren && (EXMEM_rd == IDEX_rs1))
	    rs1_sel = 2'b01;
    else if(MEMWB_rd_wren && (MEMWB_rd == IDEX_rs1))
	    rs1_sel = 2'b10;
    else rs1_sel = 2'b00;

    if(EXMEM_rd_wren && (EXMEM_rd == IDEX_rs2))
	    rs2_sel = 2'b01;
    else if(MEMWB_rd_wren && (MEMWB_rd == IDEX_rs2))
	    rs2_sel = 2'b10;
    else rs2_sel = 2'b00;
end
endmodule