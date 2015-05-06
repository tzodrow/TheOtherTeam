module EX_MEM_pipeline_reg(clk, rst_n, EX_hlt, stall, flush, EX_ov, EX_neg, EX_zero, EX_use_dst_reg, EX_branch_conditions, EX_dst_reg, EX_PC, EX_PC_out, /*EX_instr,*/ EX_ALU_result, EX_sprite_data, EX_s_data, EX_re, EX_we, EX_mem_ALU_select, EX_use_sprite_mem, EX_t_data, //Inputs
							MEM_sprite_ALU_select, MEM_mem_ALU_select, MEM_flag_ov, MEM_flag_neg, MEM_flag_zero, MEM_re, MEM_we, MEM_addr, MEM_PC, MEM_PC_out, MEM_data, MEM_sprite_data, /*MEM_instr,*/ MEM_branch_cond, MEM_use_dst_reg,
							MEM_use_sprite_mem, MEM_dst_reg, MEM_ALU_result, MEM_t_data, MEM_hlt);  //Outputs

input clk, rst_n, stall, flush, EX_hlt;
input EX_ov, EX_neg, EX_zero, EX_use_dst_reg, EX_re, EX_we, EX_mem_ALU_select, EX_use_sprite_mem;
input [2:0] EX_branch_conditions;
input [4:0] EX_dst_reg;
input [21:0] EX_PC, EX_PC_out;
input [31:0] /*EX_instr,*/ EX_ALU_result, EX_sprite_data, EX_s_data, EX_t_data;

output reg MEM_sprite_ALU_select, MEM_mem_ALU_select, MEM_flag_ov, MEM_flag_neg, MEM_flag_zero, MEM_re, MEM_we, MEM_use_dst_reg, MEM_use_sprite_mem;
output reg[2:0] MEM_branch_cond;
output reg[4:0] MEM_addr, MEM_dst_reg;
output reg[21:0] MEM_PC, MEM_PC_out;
output reg[31:0] MEM_data, MEM_sprite_data, MEM_ALU_result, MEM_t_data; /*MEM_instr*/
output reg MEM_hlt;

always @(posedge clk, negedge rst_n)
	if (!rst_n) begin
		MEM_sprite_ALU_select <= 0;
		MEM_mem_ALU_select <= 0;
		MEM_flag_ov <= 0;
		MEM_flag_neg <= 0;
		MEM_flag_zero <= 0;
		//MEM_cmd <= 0;
		MEM_addr <= 0;
		MEM_PC <= 0;
		MEM_PC_out <= 0;
		MEM_data <= 0;
		MEM_sprite_data <= 0;
		//MEM_instr <= 0;
		MEM_use_sprite_mem <= 0;
		MEM_dst_reg <= 0;
		MEM_ALU_result <= 0;
		MEM_t_data <= 0;
		MEM_use_dst_reg <= 0;
		MEM_hlt <= 0;
	end
	else if (flush) begin
		MEM_sprite_ALU_select <= 0;
		MEM_mem_ALU_select <= 0;
		MEM_flag_ov <= 0;
		MEM_flag_neg <= 0;
		MEM_flag_zero <= 0;
		//MEM_cmd <= 0;
		MEM_addr <= 0;
		MEM_PC <= 0;
		MEM_PC_out <= 0;
		MEM_data <= 0;
		MEM_sprite_data <= 0;
		//MEM_instr <= 0;
		MEM_use_sprite_mem <= 0;
		MEM_dst_reg <= 0;
		MEM_ALU_result <= 0;
		MEM_t_data <= 0;
		MEM_use_dst_reg <= 0;
		MEM_hlt <= 0;
	end 
	else if (!MEM_hlt) begin
		MEM_sprite_ALU_select <= EX_use_sprite_mem;
		MEM_mem_ALU_select <= EX_mem_ALU_select;                  
		MEM_flag_ov <= EX_ov; 
		MEM_flag_neg <= EX_neg;
		MEM_flag_zero <= EX_zero;
		MEM_re <= EX_re;
		MEM_we <=EX_we;                                  
		MEM_addr <= EX_ALU_result[21:0];                     
		MEM_PC <= EX_PC;
		MEM_PC_out <= EX_PC_out;
		MEM_data <=  EX_s_data;
		MEM_sprite_data <= EX_sprite_data;
		//MEM_instr <= EX_instr; 
		MEM_branch_cond <= EX_branch_conditions;
		MEM_use_dst_reg <= EX_use_dst_reg;
		MEM_dst_reg <= EX_dst_reg;
		MEM_ALU_result <= EX_ALU_result;
		MEM_t_data <= EX_t_data;
		MEM_hlt <= EX_hlt;
	end  
	  
endmodule 