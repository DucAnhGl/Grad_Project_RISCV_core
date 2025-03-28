module ghr_v2 #(
    HISTORY_WIDTH
)(
    input  logic                     clk_i, rst_ni,      // Clock and active-high reset
    input  logic                     update_en_i,        // Decide whether to enable updating the table or not
    input  logic                     br_taken_i,         // The true branch decision to be updated into the ghr
    input  logic [HISTORY_WIDTH-1:0] set_data,
    input  logic                     set_en,
    output logic [HISTORY_WIDTH-1:0] ghr_data_o          // The global history bits
);  

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            ghr_data_o <= 0;
        end else begin
            if (set_en) begin
                ghr_data_o <= set_data;
            end else if (update_en_i) begin
                ghr_data_o <= {ghr_data_o[HISTORY_WIDTH-2:0], br_taken_i};
            end
        end
    end

endmodule
