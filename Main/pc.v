
module pc(
		input clk,
		input rst_n,
		input [21:0] nxt_pc,
		output reg [21:0] curr_pc);
	
	// Implement the Program Counter
	always @ (posedge clk, negedge rst_n)
		if(!rst_n)
			curr_pc <= 0;
		else
			curr_pc <= nxt_pc;
	
	
endmodule
