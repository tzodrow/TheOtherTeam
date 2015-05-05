module PC_MUX(
		input [21:0] pc,
		input [21:0] br_pc,
		input taken,
		input halt,
		input stall,
		output [21:0] nxt_pc,
		output flush);
	
	assign nxt_pc = (taken) ? br_pc : 
					(halt || stall) ? pc : pc + 1;
	assign flush = taken;
	
endmodule