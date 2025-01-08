module sll (
    input  [31:0] i_operand_a,
    input  [4:0] i_operand_b,
    output reg [31:0] o_sll_data
);
    logic [31:0] temp1, temp2, temp3, temp4, temp5;
    always @(*) begin

        if(i_operand_b[0]) temp1 = {i_operand_a[30:0], 1'b0};
        else temp1 = i_operand_a;

        if(i_operand_b[1]) temp2 = {temp1[29:0], 2'b0};
        else temp2 = temp1;

        if(i_operand_b[2]) temp3 = {temp2[27:0], 4'b0};
        else temp3 = temp2;

        if(i_operand_b[3]) temp4 = {temp3[23:0], 8'b0};
        else temp4 = temp3;

        if(i_operand_b[4]) temp5 = {temp4[15:0], 16'b0};
        else temp5 = temp4;
    end

    assign o_sll_data = temp5;

endmodule
