module pc(
		input clk,
		input rst,
		input [21:0] nxt_pc,
		output reg [21:0] pc);
	
	always @ (posedge clk, posedge rst)
		if(rst)
			pc <= 0;
		else 
			pc <= nxt_pc;
		
endmodule