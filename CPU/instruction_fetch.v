module instruction_fetch(
		input clk,
		input rst,
		input [21:0] pc,
		output [31:0] instr);

	// Simulation	
	instr_mem INSTR_MEM(
		.clk(clk),
		.rst(rst),
		.addr(pc),
		.instr(instr));
		
endmodule
		