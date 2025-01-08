module ctrl_unit (
	input  logic [31:0] instr_i,

	output logic         op_a_sel_o,
	output logic  [1:0]  op_b_sel_o,
	output logic         is_br_o,
	output logic  [1:0]  is_uncbr_o,
	output logic         mem_wren_o,
	output logic         mem_rden_o,
    output logic         rd_wren_o,
	output logic         wb_sel_o,
	output logic  [1:0]  alu_ctrl_o
);

wire [6:0] func7;
wire [2:0] func3;
parameter  R_type       = 7'b0110011,
	       I_type_LD    = 7'b0000011,
	       I_type_IMM   = 7'b0010011,
	       I_type_JALR  = 7'b1100111,
	       S_type       = 7'b0100011,
	       B_type       = 7'b1100011,
	       U_type_LUI   = 7'b0110111,
		   U_type_AUIPC = 7'b0010111,
	       J_type       = 7'b1101111;

assign func7 = instr_i[31:25];
assign func3 = instr_i[14:12];

always @(*) begin
	case (instr_i[6:0])
		R_type      : begin
					  if (!(func7 == 7'b0 || func7 == 7'b0100000)) begin
						rd_wren_o = 1'b0; mem_wren_o = 1'b0; mem_rden_o = 1'b0; op_a_sel_o = 1'b0; op_b_sel_o = 2'b0; alu_ctrl_o = 4'b0000; wb_sel_o = 1'b0;
					    is_br_o = 1'b0; is_uncbr_o = 2'b00; insn_vld = 1'b0;
					  end else begin
						rd_wren_o = 1'b1; mem_wren_o = 1'b0; mem_rden_o = 1'b0; op_a_sel_o = 1'b0; op_b_sel_o = 2'b0; wb_sel_o = 1'b0;
					    is_br_o = 1'b0; is_uncbr_o = 2'b00; insn_vld = 1'b1;
						case (func3)
							3'b000: alu_ctrl_o = (!func7[5]) ? 4'b0000 : 4'b0001;
							3'b001: alu_ctrl_o = 4'b0111;
							3'b010: alu_ctrl_o = 4'b0010;
							3'b011: alu_ctrl_o = 4'b0011;
							3'b100: alu_ctrl_o = 4'b0100;
							3'b101: alu_ctrl_o = (!func7[5]) ? 4'b1000 : 4'b1001;
							3'b110: alu_ctrl_o = 4'b0101;
							3'b111: alu_ctrl_o = 4'b0110;
						endcase
					  end
		end
		I_type_IMM  : begin
			          rd_wren_o = 1'b1; mem_wren_o = 1'b0; mem_rden_o = 1'b0; op_a_sel_o = 1'b0; op_b_sel_o = 2'b01; wb_sel_o = 1'b0;
					  is_br_o = 1'b0; is_uncbr_o = 2'b00; insn_vld = 1'b1;
					  case (func3)
					    3'b000: begin
							alu_ctrl_o = 4'b0000;
							insn_vld = 1'b1;
						end
						3'b010: begin
							alu_ctrl_o = 4'b0010;
							insn_vld = 1'b1;
						end
						3'b011: begin
							alu_ctrl_o = 4'b0011;
							insn_vld = 1'b1;
						end
						3'b100: begin
							alu_ctrl_o = 4'b0100;
							insn_vld = 1'b1;
						end
						3'b110: begin
							alu_ctrl_o = 4'b0101;
							insn_vld = 1'b1;
						end
						3'b111: begin
							alu_ctrl_o = 4'b0110;
							insn_vld = 1'b1;
						end
						3'b001: begin
							if (!(func7 == 7'b0 || func7 == 7'b0100000)) begin
								alu_ctrl_o = 4'b0000;
								insn_vld = 1'b0;
							end else begin
								alu_ctrl_o = 4'b0111;
								insn_vld = 1'b0;
							end
						end
						3'b101: begin
							if (!(func7 == 7'b0 || func7 == 7'b0100000)) begin
								alu_ctrl_o = 4'b0000;
								insn_vld = 1'b0;
							end else begin
								alu_ctrl_o = (!func7[5]) ? 4'b1000 : 4'b1001;
								insn_vld = 1'b1;
							end
						end
					  endcase
		end
		I_type_JALR : begin
			          rd_wren_o = 1'b1; mem_wren_o = 1'b0; mem_rden_o = 1'b0; op_a_sel_o = 1'b0; op_b_sel_o = 2'b10; wb_sel_o = 1'b0;
					  is_br_o = 1'b0; is_uncbr_o = 2'b11; alu_ctrl_o = 4'b1010; insn_vld = 1'b1; 
		end
		I_type_LD   : begin
			          rd_wren_o = 1'b1; mem_wren_o = 1'b0; mem_rden_o = 1'b1; op_a_sel_o = 1'b0; op_b_sel_o = 2'b01; wb_sel_o = 1'b1;
					  is_br_o = 1'b0; is_uncbr_o = 2'b00; alu_ctrl_o = 4'b0000; insn_vld = 1'b1;
		end
        B_type      : begin
                      rd_wren_o = 1'b0; mem_wren_o = 1'b0; mem_rden_o = 1'b0; op_a_sel_o = 1'b0; op_b_sel_o = 2'b00; wb_sel_o = 1'b0;
					  is_br_o = 1'b1; is_uncbr_o = 2'b00; alu_ctrl_o = 4'b0000; insn_vld = 1'b1;
		end
		S_type      : begin
                      rd_wren_o = 1'b0; mem_wren_o = 1'b1; mem_rden_o = 1'b0; op_a_sel_o = 1'b0; op_b_sel_o = 2'b01; wb_sel_o = 1'b0;
					  is_br_o = 1'b0; is_uncbr_o = 2'b00; alu_ctrl_o = 4'b0000; insn_vld = 1'b1;
		end
		J_type      : begin
                      rd_wren_o = 1'b1; mem_wren_o = 1'b0; mem_rden_o = 1'b0; op_a_sel_o = 1'b0; op_b_sel_o = 2'b10; wb_sel_o = 1'b0;
					  is_br_o = 1'b0; is_uncbr_o = 2'b10; alu_ctrl_o = 4'b1010; insn_vld = 1'b1;
		end
		U_type_LUI  : begin
                      rd_wren_o = 1'b1; mem_wren_o = 1'b0; mem_rden_o = 1'b0; op_a_sel_o = 1'b0; op_b_sel_o = 2'b01; wb_sel_o = 1'b0;
					  is_br_o = 1'b0; is_uncbr_o = 2'b00; alu_ctrl_o = 4'b1010; insn_vld = 1'b1;
		end
		U_type_AUIPC: begin
                      rd_wren_o = 1'b1; mem_wren_o = 1'b0; mem_rden_o = 1'b0; op_a_sel_o = 1'b1; op_b_sel_o = 2'b01; wb_sel_o = 1'b0;
					  is_br_o = 1'b0; is_uncbr_o = 2'b00; alu_ctrl_o = 4'b0000; insn_vld = 1'b1;
		end
		default: begin
					  rd_wren_o = 1'b0; mem_wren_o = 1'b0; mem_rden_o = 1'b0; op_a_sel_o = 1'b0; op_b_sel_o = 2'b00; wb_sel_o = 1'b0;
					  is_br_o = 1'b0; is_uncbr_o = 2'b00; alu_ctrl_o = 4'b0000; insn_vld = 1'b0;
		end
                    
	endcase

end

endmodule