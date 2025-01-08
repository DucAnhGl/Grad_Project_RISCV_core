module ctrl_fsm (
	input logic clk, rstn,
	input logic  rden, wren, cs0, ack,
	output logic PC_wren, mem_ctrl_mux, reg_ctrl_mux
	//output state_out
);

	//assign state_out = state;

	parameter PROCESS = 1'b0;
	parameter STALL   = 1'b1;
	
	assign stall_cond = (rden | wren) & cs0;
	
	reg state, next_state;
	
	always @(posedge clk or negedge rstn) begin
		if (!rstn) begin
			state <= PROCESS;
		end else begin
			state <= next_state;
		end
	end
	
	always @(*) begin
		case (state)
			PROCESS: begin
				mem_ctrl_mux = 1'b0;
				if (!stall_cond) begin
					next_state = PROCESS;
					PC_wren = 1'b1;
					reg_ctrl_mux = 1'b0;
				end else begin
					if (stall_cond) begin
						next_state = STALL;
						PC_wren = 1'b0;
						reg_ctrl_mux = 1'b1;
					end
				end
			end
			STALL: begin
				mem_ctrl_mux = 1'b1;
				if (!ack) begin
					next_state = STALL;
					PC_wren = 1'b0;
					reg_ctrl_mux = 1'b1;
				end else begin
					if (ack) begin
						next_state = PROCESS;
						PC_wren = 1'b1;
						reg_ctrl_mux = 1'b0;
					end
				end
			end
		endcase
	end

endmodule