module pc_tb();
	
	reg stm_clk, stm_rst_n, stm_stall;
	reg [21:0] stm_nxt_pc;
	wire re_mon;
	wire [31:0] curr_pc_mon;
	
	
	pc pc0(
		.clk(stm_clk),
		.rst_n(stm_rst_n),
		.stall(stm_stall),
		.nxt_pc(stm_nxt_pc),
		.re(re_mon),
		.curr_pc(curr_pc_mon));
	
	
endmodule