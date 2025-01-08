module bru (
    input  logic [31:0] rs1_data_i, rs2_data_i,
    input  logic [0:0]  is_br_i, is_uncbr_i,
    input  logic [2:0]  func3_i,
    
    output logic        pc_sel_o
);
    logic [31:0] sub;
    logic overflow, carry;
    logic [0:0] br_equal, br_less, br_less_uns;

    assign {carry,sub} = rs1_data_i + ~rs2_data_i + 32'b1;
    assign overflow = (rs1_data_i[31] ^ rs2_data_i[31]) & (rs1_data_i[31] ^ sub[31]); 

    assign br_less_uns = carry;
    assign br_equal = (!sub) ? 1 : 0;
    assign br_less = sub[31] ^ overflow;

    always @(*) begin
        if (is_uncbr_i) pc_sel_o = 1'b1;
        else if (is_br_i) begin
            case (func3_i)
                3'b000: begin 
                            if (br_equal) pc_sel_o = 1'b1; 
                            else pc_sel_o = 1'b0; 
                        end
                3'b001: begin 
                            if (!br_equal) pc_sel_o = 1'b1; 
                            else pc_sel_o = 1'b0; 
                        end   
                3'b100: begin 
                            if (br_less) pc_sel_o = 1'b1; 
                            else pc_sel_o = 1'b0; 
                        end
                3'b101: begin 
                            if (!br_less || br_equal) pc_sel_o = 1'b1; 
                            else pc_sel_o = 1'b0; 
                        end
                3'b110: begin 
                            if (br_less_uns) pc_sel_o = 1'b1; 
                            else pc_sel_o = 1'b0; 
                        end
                3'b111: begin 
                            if (!br_less_uns || br_equal) pc_sel_o = 1'b1; 
                            else pc_sel_o = 1'b0; 
                        end
                default: pc_sel_o = 1'b0;
            endcase
        end else pc_sel_o = 1'b0;
    end

endmodule
