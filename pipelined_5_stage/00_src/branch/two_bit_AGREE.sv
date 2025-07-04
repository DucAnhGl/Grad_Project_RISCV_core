/*
Signals with "EXMEM" prefix indicates that they come from the branch commit stage,
which is in default the MEM stage.
*/

module two_bit_AGREE #(
    PHT_INDEX_WIDTH,
    BTB_INDEX_WIDTH
) (
    input logic                              clk_i, rst_ni,
    input logic [(32-BTB_INDEX_WIDTH-2)-1:0] IF_PC_tag_i,              // Tag field of Fetch stage's PC
    input logic [(BTB_INDEX_WIDTH-1):0]      IF_btb_rd_index_i,        // Read index of btb
    input logic [(BTB_INDEX_WIDTH-1):0]      EXMEM_btb_wr_index_i,     // Write index of btb

    input logic [(PHT_INDEX_WIDTH-1):0]      IF_pht_rd_index_i,        // Read index ofpht
    input logic [(PHT_INDEX_WIDTH-1):0]      EXMEM_pht_wr_index_i,     // Write index of pht

    input logic [(32-BTB_INDEX_WIDTH-2)-1:0] EXMEM_btb_wr_tag_i,       // New tag to write to btb
    input logic [31:0]                       EXMEM_btb_wr_target_i,    // New target PC to write to btb
    input logic                              EXMEM_btb_hit_i,          // Whether there was a hit in the btb 
    input logic                              EXMEM_br_decision_i,      // Branch decision in the branch commit stage
    input logic                              EXMEM_is_jmp_i,           // Whether the instruction is a branch or unconditional branch
    input logic                              EXMEM_prediction_i,       // Prediction the predictor has made for this branch back at Fetch  
    input  logic                             EXMEM_bias_i,
    input logic                              EXMEM_btb_valid_i,
    
    output logic                             IF_btb_hit_o,             // Whether the instruction in the Fetch stage "hit"
    output logic                             IF_prediction_o,          // The prediction the predictor make
    output logic [1:0]                       IF_PCnext_sel_o,          // Selection for the PCnext MUX:
                                                                   // 2'b00: IF_PCplus4;    2'b01: EXMEM_PCplus4, 
                                                                   // 2'b10: IF_btb_target; 2'b11: EXMEM_br_target 
    output logic                             IF_bias_o,
    output logic                             IF_btb_valid_o,
    output logic [31:0]                      IF_btb_rd_target_o,       // Target read from btb in Fetch stage
    output logic                             IF_flush_o                // Flush signal for penalty when prediction is wrong
);


    logic btb_wren;
    logic pht_update_en;
    logic pht_predictor_bit;
    logic [(32-BTB_INDEX_WIDTH-2)-1:0] IF_btb_rd_tag;

    assign btb_wren           = (~EXMEM_btb_hit_i) & EXMEM_is_jmp_i;   // btb update condition: If the instruction was a branch and it was a miss
    assign pht_update_en      = (EXMEM_is_jmp_i & EXMEM_btb_hit_i /*& EXMEM_btb_valid_i*/);                        // pht update condition: If the instruction was a branch
    assign IF_btb_hit_o       = ((IF_PC_tag_i == IF_btb_rd_tag) && (IF_btb_valid_o)) ? 1'b1 : 1'b0;
    assign IF_prediction_o   = IF_btb_hit_o & (pht_predictor_bit ~^ IF_bias_o);

    agree_btb #(
        .INDEX_WIDTH(BTB_INDEX_WIDTH)
    ) u_btb (
        .clk_i       (clk_i),
        .rst_ni      (rst_ni),
        .rd_index_i  (IF_btb_rd_index_i),
        .wr_index_i  (EXMEM_btb_wr_index_i),
        .wren_i      (btb_wren),
        .wr_target_i (EXMEM_btb_wr_target_i),
        .wr_tag_i    (EXMEM_btb_wr_tag_i),
        .br_taken_i  (EXMEM_br_decision_i),

        .valid_o     (IF_btb_valid_o),
        .rd_target_o (IF_btb_rd_target_o),
        .rd_tag_o    (IF_btb_rd_tag),
        .bias_o      (IF_bias_o)
    );

    pht #(
        .INDEX_WIDTH(PHT_INDEX_WIDTH)
    ) pht_inst (
        .clk_i           (clk_i),
        .rst_ni          (rst_ni),
        .update_en_i     (pht_update_en),
        .update_index_i  (EXMEM_pht_wr_index_i),
        .br_taken_i      (EXMEM_br_decision_i ~^ EXMEM_bias_i),
        .rd_index_i      (IF_pht_rd_index_i),
        .br_prediction_o (pht_predictor_bit)
    );

    //Next PC selection decoder: 
    always @(*) begin
        if (EXMEM_is_jmp_i) begin                            // need to check if prediction was correct
            case ({EXMEM_prediction_i, EXMEM_br_decision_i})
                2'b00, 2'b11: begin                          // prediction was correct: Follow predictor to predict next PC
                    if (IF_prediction_o) begin               // If it's predicted taken
                        IF_PCnext_sel_o = 2'b10;             // take stored target as next PC
                        IF_flush_o      = 1'b0;
                    end else begin
                        IF_PCnext_sel_o = 2'b00;             // If it's a miss in btb or it's predicted not taken, take PC+4 as next address
                        IF_flush_o      = 1'b0;
                    end
                end
                2'b10: begin                                 // predicted branch, but actually not branch
                    IF_PCnext_sel_o = 2'b01;                 // recover to PCplus4
                    IF_flush_o      = 1'b1;                  // Flush wrong instructions
                end
                2'b01: begin                                 // predicted not branch, but actually branch
                    IF_PCnext_sel_o = 2'b11;                 // recover to correct branch target
                    IF_flush_o      = 1'b1;                  // Flush wrong instructions
                end
            endcase
        end else begin
            if (EXMEM_br_decision_i) begin
                IF_PCnext_sel_o = 2'b11;                 // If it's a miss in btb or it's predicted not taken, but actually branch, recover to correct branch target
                IF_flush_o      = 1'b1;
            end else begin
                if (IF_prediction_o) begin                       // If it's predicted taken
                    IF_PCnext_sel_o = 2'b10;                 // take stored target as next PC
                    IF_flush_o      = 1'b0;
                end else begin
                    IF_PCnext_sel_o = 2'b00;                 // If it's a miss in btb or it's predicted not taken, take PC+4 as next address
                    IF_flush_o      = 1'b0;
                end
            end
        end
    end
    
endmodule
