module adder (
    input  logic [31:0] operand_a_i,
    input  logic [31:0] operand_b_i,

    output logic [31:0] adder_data_o
);

    assign adder_data_o = operand_a_i + operand_b_i;

endmodule
