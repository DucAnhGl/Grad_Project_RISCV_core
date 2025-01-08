module immgen (
	input [31:0] instruction_i,
    output reg [31:0] immediate_o	
);


parameter  R_type       = 7'b0110011,
	       I_type_LD    = 7'b0000011,
	       I_type_IMM   = 7'b0010011,
	       I_type_JALR  = 7'b1100111,
	       S_type       = 7'b0100011,
	       B_type       = 7'b1100011,
	       U_type_LUI   = 7'b0110111,
		   U_type_AUIPC = 7'b0010111,
	       J_type       = 7'b1101111;

//wire opcode [4:0];

//assign opode = instruction_i[6:2];

always @(*) begin
	case (instruction_i[6:0])
		R_type      : immediate_o = 32'h00000000;

		I_type_LD   : immediate_o = { {20{instruction_i[31]}}, instruction_i[31:20] };
		I_type_IMM  : immediate_o = { {20{instruction_i[31]}}, instruction_i[31:20] };
		I_type_JALR : immediate_o = { {20{instruction_i[31]}}, instruction_i[31:20] };

		S_type      : immediate_o = { {20{instruction_i[31]}}, instruction_i[31:25], instruction_i[11:7] };
		B_type      : immediate_o = { {20{instruction_i[31]}}, instruction_i[7], instruction_i[30:25], instruction_i[11:8], 1'b0 };
		U_type_LUI  : immediate_o = { instruction_i[31:12], 12'b000000000000 };
		U_type_AUIPC: immediate_o = { instruction_i[31:12], 12'b000000000000 };
		J_type      : immediate_o = { {11{instruction_i[31]}}, instruction_i[31], instruction_i[19:12], instruction_i[20], instruction_i[30:21], 1'b0 };	
		default     : immediate_o = 32'h00000000;
	endcase

end

endmodule