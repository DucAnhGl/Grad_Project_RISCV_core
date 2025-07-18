module sra (
    input  logic [31:0] operand_a_i, 
    input  logic [4:0]  operand_b_i,
    
    output logic [31:0] sra_data_o
);

    logic [31:0] temp1, temp2, temp3, temp4, temp5;
    always @(*) begin

        if(operand_b_i[0]) temp1 = {{1{operand_a_i[31]}}, operand_a_i[31:1]};
        else temp1 = operand_a_i;

        if(operand_b_i[1]) temp2 = {{2{temp1[31]}}, temp1[31:2]};
        else temp2 = temp1;

        if(operand_b_i[2]) temp3 = {{4{temp2[31]}}, temp2[31:4]};
        else temp3 = temp2;

        if(operand_b_i[3]) temp4 = {{8{temp3[31]}}, temp3[31:8]};
        else temp4 = temp3;

        if(operand_b_i[4]) temp5 = {{16{temp4[31]}}, temp4[31:16]};
        else temp5 = temp4;
    end

    assign sra_data_o = temp5;

endmodule
