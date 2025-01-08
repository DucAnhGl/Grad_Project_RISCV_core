module adder (
    input  [31:0] operand_a, operand_b,
    output [31:0] adder_data
);

assign adder_data = operand_a + operand_b;

endmodule