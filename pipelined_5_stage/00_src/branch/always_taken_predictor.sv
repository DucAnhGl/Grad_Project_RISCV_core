/*
Signals with "EXMEM" prefix indicates that they come from the branch commit stage,
which is in default the MEM stage.
*/

module always_taken_predictor #(
    INDEX_WIDTH
) (
    input logic                          clk_i, rst_ni,
    input logic [(32-INDEX_WIDTH-2)-1:0] IF_PC_tag_i,              // Tag field of Fetch stage's PC
    input logic [(INDEX_WIDTH-1):0]      IF_btb_rd_index_i,        // Read index of btb
    input logic [(INDEX_WIDTH-1):0]      EXMEM_btb_wr_index_i,     // Write index of btb
    input logic [(32-INDEX_WIDTH-2)-1:0] EXMEM_btb_wr_tag_i,       // New tag to write to btb
    input logic [31:0]                   EXMEM_btb_wr_target_i,    // New target PC to write to btb
    input logic                          EXMEM_btb_hit_i,          // Whether there was a hit in the btb 
    input logic                          EXMEM_is_jmp_i,           // Whether the instruction is a branch or unconditional branch    
    
    output logic                         IF_btb_hit_o,               // Whether the instruction in the Fetch stage "hit"                                                                   // 2'b00: IF_PCplus4;    2'b01: EXMEM_PCplus4,                                                                    // 2'b10: IF_btb_target; 2'b11: EXMEM_br_target 
    output logic [31:0]                  IF_btb_rd_target_o       // Target read from btb in Fetch stage
);


    logic btb_wren;
    logic btb_valid;
    logic [(32-INDEX_WIDTH-2)-1:0] IF_btb_rd_tag;

    assign btb_wren     = (~EXMEM_btb_hit_i) & EXMEM_is_jmp_i;   // btb update condition: If the instruction was a branch and it was a miss
    assign IF_btb_hit_o = ((IF_PC_tag_i == IF_btb_rd_tag) && (btb_valid)) ? 1'b1 : 1'b0;

    btb #(
        .INDEX_WIDTH(INDEX_WIDTH)
    ) u_btb (
        .clk_i       (clk_i),
        .rst_ni      (rst_ni),
        .rd_index_i  (IF_btb_rd_index_i),
        .wr_index_i  (EXMEM_btb_wr_index_i),
        .wren_i      (btb_wren),
        .wr_target_i (EXMEM_btb_wr_target_i),
        .wr_tag_i    (EXMEM_btb_wr_tag_i),

        .valid_o     (btb_valid),
        .rd_target_o (IF_btb_rd_target_o),
        .rd_tag_o    (IF_btb_rd_tag)
    );
    
endmodule
