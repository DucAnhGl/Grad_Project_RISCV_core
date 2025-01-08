module sra (
    input  [31:0] i_operand_a, 
    input  [4:0] i_operand_b,
    output reg [31:0] o_sra_data
);

    logic [31:0] temp1, temp2, temp3, temp4, temp5;
    always @(*) begin

        if(i_operand_b[0]) temp1 = {{1{i_operand_a[31]}}, i_operand_a[31:1]};
        else temp1 = i_operand_a;

        if(i_operand_b[1]) temp2 = {{2{temp1[31]}}, temp1[31:2]};
        else temp2 = temp1;

        if(i_operand_b[2]) temp3 = {{4{temp2[31]}}, temp2[31:4]};
        else temp3 = temp2;

        if(i_operand_b[3]) temp4 = {{8{temp3[31]}}, temp3[31:8]};
        else temp4 = temp3;

        if(i_operand_b[4]) temp5 = {{16{temp4[31]}}, temp4[31:16]};
        else temp5 = temp4;
    end

    assign o_sra_data = temp5;

endmodule
