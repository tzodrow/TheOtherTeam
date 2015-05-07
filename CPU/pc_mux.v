module pc_mux(
		input [21:0] curr_pc,
		input [21:0] immd,
		input [21:0] reg_data,
		input reg_sel,
		input immd_sel,
		output nxt_pc);
	
	assign nxt_pc = (reg_sel) ? reg_data :
					(immd_sel) ? immd : curr_pc + 1;
	
endmodule