module pc(
		input clk,
		input rst_n,
		input stall,
		input [21:0] nxt_pc,
		output re,
		output reg [21:0] curr_pc);

	assign re = ~stall;
	
	// Implement the Program Counter
	always @ (posedge clk, negedge clk_n)
		if(!rst_n)
			curr_pc <= 0;
		else
			curr_pc <= nxt_pc;
	
	
endmodule