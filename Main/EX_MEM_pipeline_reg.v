module EX_MEM_pipeline_reg(clk, rst_n, hlt, stall, flush, EX_ov, EX_neg, EX_zero, EX_use_dst_reg, EX_branch_conditions, EX_dst_reg, EX_PC, EX_PC_out, EX_instr, EX_ALU_result, EX_sprite_data,  //Inputs
							MEM_sprite_ALU_select, MEM_mem_ALU_select, MEM_flag_ov, MEM_flag_neg, MEM_flag_zero, MEM_cmd, MEM_addr, MEM_PC, MEM_PC_out, MEM_data, MEM_sprite_data, MEM_instr, MEM_branch_cond;);  //Outputs

input clk, rst_n, stall, flush, hlt;
input EX_ov, EX_neg, EX_zero, EX_use_dst_reg;
input [2:0] EX_branch_conditions;
input [4:0] EX_dst_reg;
input [21:0] EX_PC, EX_PC_out;
input [31:0] EX_instr, EX_ALU_result, EX_sprite_data;

output MEM_sprite_ALU_select, MEM_mem_ALU_select, MEM_flag_ov, MEM_flag_neg, MEM_flag_zero, MEM_cmd;
output [2:0] MEM_branch_cond;
output [4:0] MEM_addr;
output [21:0] MEM_PC, MEM_PC_out;
output [31:0] MEM_data, MEM_sprite_data, MEM_instr;

always @(posedge clk, negedge rst_n)
	if (!rst_n) begin
		MEM_sprite_ALU_select <= 0;
		MEM_mem_ALU_select <= 0;
		MEM_flag_ov <= 0;
		MEM_flag_neg <= 0;
		MEM_flag_zero <= 0;
		MEM_cmd <= 0;
		MEM_addr <= 0;
		MEM_PC <= 0;
		MEM_PC_out <= 0;
		MEM_data <= 0;
		MEM_sprite_data <= 0;
		MEM_instr <= 0;
	end
	else if (flush) begin
		MEM_sprite_ALU_select <= 0;
		MEM_mem_ALU_select <= 0;
		MEM_flag_ov <= 0;
		MEM_flag_neg <= 0;
		MEM_flag_zero <= 0;
		MEM_cmd <= 0;
		MEM_addr <= 0;
		MEM_PC <= 0;
		MEM_PC_out <= 0;
		MEM_data <= 0;
		MEM_sprite_data <= 0;
		MEM_instr <= 0;
	end 
	else if (!stall & !hlt) begin
		MEM_sprite_ALU_select <= EX_use_dst_reg;
		//MEM_mem_ALU_select <=                        //Need Signal
		MEM_flag_ov <= EX_ov; 
		MEM_flag_neg <= EX_neg;
		MEM_flag_zero <= EX_zero;
		MEM_cmd
		MEM_addr <= EX_dst_reg;                         //Not sure if this is the correct signal to send
		MEM_PC <= EX_PC;
		MEM_PC_out <= EX_PC_out;
		MEM_data <= EX_ALU_result;
		MEM_sprite_data <= EX_sprite_data;
		MEM_instr <= EX_instr; 
		MEM_branch_cond <= EX_branch_conditions;
	end  
	  
endmodule 
