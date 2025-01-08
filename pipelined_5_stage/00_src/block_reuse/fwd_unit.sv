module fwd_unit(
    input  logic [4:0] IDEX_rs1_i, IDEX_rs2_i,
    input  logic [4:0] EXMEM_rd_i, MEMWB_rd_i,       
    input  logic       EXMEM_rd_i_wren_i, MEMWB_rd_i_wren_i,

    output logic [1:0] rs1_sel_o, rs2_sel_o
);
    always @(*) begin
        if (EXMEM_rd_i_wren_i && (EXMEM_rd_i == IDEX_rs1_i))
            rs1_sel_o = 2'b01;
        else if (MEMWB_rd_i_wren_i && (MEMWB_rd_i == IDEX_rs1_i))
            rs1_sel_o = 2'b10;
        else rs1_sel_o = 2'b00;

        if (EXMEM_rd_i_wren_i && (EXMEM_rd_i == IDEX_rs2_i))
            rs2_sel_o = 2'b01;
        else if (MEMWB_rd_i_wren_i && (MEMWB_rd_i == IDEX_rs2_i))
            rs2_sel_o = 2'b10;
        else rs2_sel_o = 2'b00;
    end
endmodule
