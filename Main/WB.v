module WB(
	input clk, 
	input rst_n, 
	input [31:0] mem_result, 
	input [31:0] sprite_ALU_result, 
	input mem_ALU_select,
	output reg_WB_data);
		  
	assign reg_WB_data = (mem_ALU_select) ?  mem_result : sprite_ALU_result;

endmodule