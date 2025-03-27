module imem (
    input  logic        clk_i,
    input  logic [31:0] addr_i,

    output logic [31:0] data_o
);

    logic [7:0] instr_mem [0:65535]; // 64k

    initial
    $readmemh("../02_sim/instruction_mem.mem",instr_mem);

    always @(posedge clk_i) begin
        //data_o <= instr_mem[addr_i];
        data_o <= {instr_mem[addr_i+32'h0000_0003], instr_mem[addr_i+32'h0000_0002], instr_mem[addr_i+32'h0000_0001], instr_mem[addr_i]};
    end

    //assign data_o = {instr_mem[addr_i+32'h0000_0003], instr_mem[addr_i+32'h0000_0002], instr_mem[addr_i+32'h0000_0001], instr_mem[addr_i]};

    //logic [31:0] instr_mem [0:8191];

    // initial 
    // $readmemh("../02_sim/instruction_mem_padded.mem",instr_mem);

    // assign data_o = instr_mem[addr_i];

endmodule
