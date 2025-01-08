module regfile (
    input  logic        clk_i, rst_ni, 
    input  logic        rd_wren_i,
    input  logic [4:0]  rd_addr_i, rs1_addr_i, rs2_addr_i,
    input  logic [31:0] rd_data_i,

    output logic [31:0] rs1_data_o, rs2_data_o
);
    
// Register file initialization
    logic [31:0] register[0:31];

// Write operation
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            for (integer i = 0; i < 32; i++) begin
                register[i] <= '0;
            end
        end else if (rd_wren_i && (rd_addr_i!=0)) register[rd_addr_i] <= rd_data_i;
    end

// Read operation
    assign rs1_data_o = ((rd_addr_i != 5'b00_000) && (rd_addr_i == rs1_addr_i) && rd_wren_i) ? rd_data_i : register[rs1_addr_i];
    assign rs2_data_o = ((rd_addr_i != 5'b00_000) && (rd_addr_i == rs2_addr_i) && rd_wren_i) ? rd_data_i : register[rs2_addr_i];

endmodule
