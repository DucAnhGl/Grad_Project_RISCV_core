module imem (
    input  logic [31:0] i_addr,
    output logic [31:0] o_data
);

reg [7:0] instr_mem [0:8191];

initial
$readmemh("../02_test/dump/mem.dump",instr_mem);

assign o_data = {instr_mem[i_addr+32'h0000_0003], instr_mem[i_addr+32'h0000_0002], instr_mem[i_addr+32'h0000_0001], instr_mem[i_addr]};

endmodule