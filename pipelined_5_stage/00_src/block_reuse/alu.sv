module alu (
    input  [31:0] operand_a_i, operand_b_i,
    input  [3:0]  alu_op_i,
    output [31:0] alu_data_o
);
logic [31:0] temp, temp_sll, temp_srl, temp_sra;
logic [31:0] alu_temp;
logic [0:0]  carry, overflow, signed_lt, unsigned_lt;

assign {carry,temp} = operand_a_i + ~operand_b_i + 32'h1;
assign overflow     = (operand_a_i[31] ^ operand_b_i[31]) & (operand_a_i[31] ^ temp[31]);
assign signed_lt    = temp[31] ^ overflow;
assign unsigned_lt  = carry;

sll u1(
    .operand_a_i(operand_a_i),
    .operand_b_i(operand_b_i[4:0]),
    .o_sll_data(temp_sll)
);
srl u2(
    .operand_a_i(operand_a_i),
    .operand_b_i(operand_b_i[4:0]),
    .o_srl_data(temp_srl)
);
sra u3(
    .operand_a_i(operand_a_i),
    .operand_b_i(operand_b_i[4:0]),
    .o_sra_data(temp_sra)
);

always @(*) begin
    case (alu_op_i)
        4'h0: alu_temp = operand_a_i + operand_b_i;
        4'h1: alu_temp = temp;
        4'h2: alu_temp = {31'h0, signed_lt};
        4'h3: alu_temp = {31'h0, unsigned_lt};
        4'h4: alu_temp = operand_a_i ^ operand_b_i;
        4'h5: alu_temp = operand_a_i | operand_b_i;
        4'h6: alu_temp = operand_a_i & operand_b_i;
        4'h7: alu_temp = temp_sll;
        4'h8: alu_temp = temp_srl;
        4'h9: alu_temp = temp_sra;
        4'hA: alu_temp = operand_b_i;
    default: alu_temp = 32'h00000000; 
    endcase
end

assign alu_data_o = alu_temp;
endmodule