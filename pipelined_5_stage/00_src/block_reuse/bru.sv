module bru (
    input  logic [31:0] rs1_data_i,
    input  logic [31:0] rs2_data_i,
    input  logic        is_br_i,
    input  logic        is_uncbr_i,
    input  logic [2:0]  funct3_i,

    output logic        true_br_decision_o
);
    logic [31:0] sub, not_rs2_data;
    logic overflow, carry;
    logic [0:0] br_equal, br_less, br_less_uns;

    assign not_rs2_data = ~rs2_data_i;

    assign {carry,sub} = rs1_data_i + not_rs2_data + 32'b1;
    assign overflow = (rs1_data_i[31] ^ rs2_data_i[31]) & (rs1_data_i[31] ^ sub[31]); 

    assign br_less_uns = ~carry;
    assign br_equal = (sub==0) ? 1 : 0;
    assign br_less = sub[31] ^ overflow;

    always @(*) begin
        if (is_uncbr_i) true_br_decision_o = 1'b1;
        else if (is_br_i) begin
            case (funct3_i)
                3'b000: begin 
                            if (br_equal) true_br_decision_o = 1'b1; 
                            else true_br_decision_o = 1'b0; 
                        end
                3'b001: begin 
                            if (!br_equal) true_br_decision_o = 1'b1; 
                            else true_br_decision_o = 1'b0; 
                        end   
                3'b100: begin 
                            if (br_less) true_br_decision_o = 1'b1; 
                            else true_br_decision_o = 1'b0; 
                        end
                3'b101: begin 
                            if (!br_less || br_equal) true_br_decision_o = 1'b1; 
                            else true_br_decision_o = 1'b0; 
                        end
                3'b110: begin 
                            if (br_less_uns) true_br_decision_o = 1'b1; 
                            else true_br_decision_o = 1'b0; 
                        end
                3'b111: begin 
                            if (!br_less_uns || br_equal) true_br_decision_o = 1'b1; 
                            else true_br_decision_o = 1'b0; 
                        end
                default: true_br_decision_o = 1'b0;
            endcase
        end else true_br_decision_o = 1'b0;
    end

endmodule
