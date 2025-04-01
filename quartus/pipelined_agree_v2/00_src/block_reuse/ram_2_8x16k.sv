module ram_2_8x16k (
    input clk_i, wren_i,
    input [13:0] addr_i, // Address for read and write
    input [7:0] wdata_i, // Data to store into memory
    
    output [7:0] rdata_o // Data read out of memory
);

    //Memory array creation
    logic [7:0] data_mem [0:16383];

    initial begin
      $readmemh("../../02_dmemdata/ram2.mem", data_mem);
    end

    //Synchronous write, synchronous enable
    always @(posedge clk_i) begin
		if (wren_i) data_mem[addr_i] <= wdata_i;
    end

    //Read operation
    assign rdata_o = data_mem[addr_i];
    
endmodule
