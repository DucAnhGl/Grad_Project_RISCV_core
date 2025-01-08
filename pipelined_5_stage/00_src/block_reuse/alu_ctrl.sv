module alu_ctrl (
    input  logic [2:0] funct3_i,
    input  logic [6:0] funct7_i,
    input  logic [1:0] alu_ctrl_i,
    
    output logic [3:0] alu_op_o
);

    always @(*) begin
		case (alu_ctrl_i)
			2'b00: begin
				     if ( (funct3_i==3'b000) && (funct7_i==7'b0000000) ) alu_op_o = 4'h0; // Add
				else if ( (funct3_i==3'b000) && (funct7_i==7'b0100000) ) alu_op_o = 4'h1; // Sub

                else if ( (funct3_i==3'b010) && (funct7_i==7'b0000000) ) alu_op_o = 4'h2; // Slt
                else if ( (funct3_i==3'b011) && (funct7_i==7'b0000000) ) alu_op_o = 4'h3; // Sltu

                else if ( (funct3_i==3'b100) && (funct7_i==7'b0000000) ) alu_op_o = 4'h4; // Xor
                else if ( (funct3_i==3'b110) && (funct7_i==7'b0000000) ) alu_op_o = 4'h5; // Or
                else if ( (funct3_i==3'b111) && (funct7_i==7'b0000000) ) alu_op_o = 4'h6; // And

				else if ( (funct3_i==3'b001) && (funct7_i==7'b0000000) ) alu_op_o = 4'h7; // Sll
				else if ( (funct3_i==3'b101) && (funct7_i==7'b0000000) ) alu_op_o = 4'h8; // Srl
				else if ( (funct3_i==3'b101) && (funct7_i==7'b0100000) ) alu_op_o = 4'h9; // Sra
				
				
			end

			2'b01: alu_op_o = 4'h0; // Load-Store, AUIPC: Add
			2'b10: alu_op_o = 4'hA; // JAL, JALR, LUI: out operand_b

			default: alu_op_o = 4'h0; 

		endcase
	end

endmodule
