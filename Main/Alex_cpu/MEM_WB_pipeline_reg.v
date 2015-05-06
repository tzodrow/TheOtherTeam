
module MEM_WB_pipeline_reg(clk, rst_n, MEM_hlt, stall, flush, MEM_mem_ALU_select, MEM_PC, MEM_PC_out, MEM_ALU_result, MEM_sprite_ALU_result, MEM_instr, MEM_use_dst_reg, MEM_dst_reg, MEM_mem_result, //Inputs
			   WB_mem_ALU_select, WB_PC, WB_PC_out, WB_mem_result, WB_sprite_ALU_result, WB_instr, WB_use_dst_reg, WB_dst_reg, WB_hlt);  //Outputs

input clk, rst_n, stall, flush, MEM_hlt;

input MEM_mem_ALU_select, MEM_use_dst_reg;
input [4:0] MEM_dst_reg;
input [21:0] MEM_PC, MEM_PC_out;
input [31:0] MEM_ALU_result, MEM_sprite_ALU_result, MEM_instr, MEM_mem_result; 

output reg[4:0] WB_dst_reg;
output reg WB_mem_ALU_select, WB_use_dst_reg;
output reg[21:0] WB_PC, WB_PC_out;
output reg[31:0] WB_mem_result, WB_sprite_ALU_result, WB_instr; 
output reg WB_hlt;

always @(posedge clk, negedge rst_n)
	if (!rst_n) begin
		WB_mem_ALU_select <= 0;
		WB_PC <= 0;
		WB_PC_out <= 0;
		WB_mem_result <= 0;
		WB_sprite_ALU_result <= 0;
		WB_instr <= 0;
		WB_use_dst_reg <= 0;
		WB_dst_reg <= 0;
		WB_hlt <= 0;
	end
	else if (flush) begin
		WB_mem_ALU_select <= 0;
		WB_PC <= 0;
		WB_PC_out <= 0;
		WB_mem_result <= 0;
		WB_sprite_ALU_result <= 0;
		WB_instr <= 0;
		WB_use_dst_reg <= 0;
		WB_dst_reg <= 0;
		WB_hlt <= 0;
	end 
	else if (!WB_hlt) begin
		WB_mem_ALU_select <= MEM_mem_ALU_select;
		WB_PC <= MEM_PC;
		WB_PC_out <= MEM_PC_out;
		WB_mem_result <= MEM_mem_result;
		WB_sprite_ALU_result <= MEM_sprite_ALU_result;
		WB_instr <= MEM_instr;
		WB_use_dst_reg <= MEM_use_dst_reg;
		WB_dst_reg <= MEM_dst_reg;
		WB_hlt <= MEM_hlt;
	end  
	  
endmodule