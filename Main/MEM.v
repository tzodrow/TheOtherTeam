module MEM(clk, rst_n, mem_data, addr, cmd, sprite_data, sprite_ALU_select, mem_ALU_select, //Inputs
		   cache_hit, mem_ALU_WB_select, sprite_ALU_result, mem_result); //Outputs
		   
	input clk ,rst_n, cmd, sprite_ALU_select, mem_ALU_select;
	input [31:0] mem_data, sprite_data;
	input [21:0] addr;
	output cache_hit, mem_ALU_WB_select;
	output [31:0] sprite_ALU_result, mem_result;
		
	mainMemory mainMem(.clk(clk),.rst_n(rst_n),.data(mem_data),.addr(addr),.cmd(cmd), //Inputs
					 .result(mem_result),.cache_hit(cache_hit)); //Outputs
	
	assign sprite_ALU_result = (sprite_ALU_select) ? mem_data : sprite_data;
	
	assign mem_ALU_WB_select = mem_ALU_select;
	
endmodule
