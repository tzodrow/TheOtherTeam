module instr_fetch(
		input clk,
		input rst_n,
		input [21:0] addr,
		output [31:0] instr
		);
	
	instr_mem im0(clk, rst_n, addr, instr);
	
endmodule
