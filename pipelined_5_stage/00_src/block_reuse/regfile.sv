module regfile (
    input         clk_i, rd_wren, rst_ni,
    input  [4:0]  rd_addr, rs1_addr, rs2_addr,
    input  [31:0] rd_data,
    output [31:0] rs1_data, rs2_data
);
    
// Register file initialization
    reg [31:0] register[0:31];

// Write operation
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            for (integer i = 0; i < 32; i++) begin
                register[i] <= '0;
            end
        end else if (rd_wren && rd_addr) register[rd_addr] <= rd_data;
    end

// Read operation
    assign rs1_data = ((rd_addr != 5'b00_000) && (rd_addr == rs1_addr) && rd_wren) ? rd_data : register[rs1_addr];
    assign rs2_data = ((rd_addr != 5'b00_000) && (rd_addr == rs2_addr) && rd_wren) ? rd_data : register[rs2_addr];

endmodule