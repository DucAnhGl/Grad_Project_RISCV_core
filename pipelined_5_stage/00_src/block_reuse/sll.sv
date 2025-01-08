module sll (
    input  logic [31:0] operand_a_i,
    input  logic [4:0]  operand_b_i,

    output logic [31:0] sll_data_o
);
    logic [31:0] temp1, temp2, temp3, temp4, temp5;
    always @(*) begin

        if(operand_b_i[0]) temp1 = {operand_a_i[30:0], 1'b0};
        else temp1 = operand_a_i;

        if(operand_b_i[1]) temp2 = {temp1[29:0], 2'b0};
        else temp2 = temp1;

        if(operand_b_i[2]) temp3 = {temp2[27:0], 4'b0};
        else temp3 = temp2;

        if(operand_b_i[3]) temp4 = {temp3[23:0], 8'b0};
        else temp4 = temp3;

        if(operand_b_i[4]) temp5 = {temp4[15:0], 16'b0};
        else temp5 = temp4;
    end

    assign sll_data_o = temp5;

endmodule
