module adder (
    input  logic [31:0] operand_a_i, operand_b,

    output logic [31:0] adder_data_o
);

    assign adder_data_o = operand_a_i + operand_b;

endmodule
