module insn_vld_dec (
    input  logic [31:0] instr_i,
    
    output logic        insn_vld_o
);

wire [6:0] funct7;
wire [2:0] funct3;
parameter  R_type       = 7'b0110011,
	       I_type_LD    = 7'b0000011,
	       I_type_IMM   = 7'b0010011,
	       I_type_JALR  = 7'b1100111,
	       S_type       = 7'b0100011,
	       B_type       = 7'b1100011,
	       U_type_LUI   = 7'b0110111,
		   U_type_AUIPC = 7'b0010111,
	       J_type       = 7'b1101111;

assign funct7 = instr_i[31:25];
assign funct3 = instr_i[14:12];

always @(*) begin
	case (instr_i[6:0])
		R_type      : begin
                        if (funct7 != 7'b0100000 && funct7 != 7'b0000000) insn_vld = 0;
                        else                                              insn_vld = 1;
		end
		I_type_IMM  : begin
                        case (funct3) 
                        3'b001: begin
                            if (funct7 != 7'b0000000) insn_vld = 0;
                            else                      insn_vld = 1;
                        end
                        3'b101: begin
                            if (funct7 != 7'b0100000 && funct7 != 7'b0000000) insn_vld = 0;
                            else                                              insn_vld = 1;
                        end
                        default: insn_vld = 1;
                        endcase
		end
		I_type_JALR : begin
                        insn_vld = 1;
		end
		I_type_LD   : begin
                        insn_vld = 1;
		end
        B_type      : begin
                        insn_vld = 1;
		end
		S_type      : begin
                        insn_vld = 1;
		end
		J_type      : begin
                        insn_vld = 1;
		end
		U_type_LUI  : begin
                        insn_vld = 1;
		end
		U_type_AUIPC: begin
                        insn_vld = 1;
		end
		default:      begin
                        insn_vld = 0;
		end
                    
	endcase

end
endmodule
