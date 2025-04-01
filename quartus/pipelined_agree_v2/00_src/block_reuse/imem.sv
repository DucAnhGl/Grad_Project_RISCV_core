module imem (
    input  logic        clk_i,
    input  logic        rden_i,
    input  logic [31:0] addr_i,

    output logic [31:0] data_o
);

    logic [7:0] instr_mem [0:16383]; // 16k

    initial
		$readmemh("../../01_imemdata/instruction_mem_padded.mem",instr_mem);

    always @(posedge clk_i) begin
        if (rden_i)
            data_o <= instr_mem[addr_i];
    end

endmodule
