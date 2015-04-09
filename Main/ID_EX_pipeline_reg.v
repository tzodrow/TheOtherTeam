module ID_EX_pipeline_reg(clk, rst_n, stall, hlt, flush, ID_PC, ID_PC_out, ID_instr, ID_s_data, ID_t_data, ID_use_imm, 
	ID_use_dst_reg, ID_update_neg, ID_update_carry, ID_update_ov, ID_update_zero, ID_alu_opcode, ID_branch_conditions,
	ID_imm, ID_dst_reg, ID_sprite_addr, ID_sprite_action, ID_sprite_use_imm, ID_sprite_re, ID_sprite_we, 
	ID_sprite_use_dst_reg, ID_sprite_imm, EX_PC, EX_PC_out, EX_instr, EX_s_data, EX_t_data, EX_use_imm, 
	EX_use_dst_reg, EX_update_neg, EX_update_carry, EX_update_ov, EX_update_zero, EX_alu_opcode, EX_branch_conditions,
	EX_imm, EX_dst_reg, EX_sprite_addr, EX_sprite_action, EX_sprite_use_imm, EX_sprite_re, EX_sprite_we, 
	EX_sprite_use_dst_reg, EX_sprite_imm);

input clk, rst_n, stall, flush, hlt;

//ID Stage input Declarations
input[21:0] ID_PC, ID_PC_out;
input[31:0] ID_instr, ID_s_data, ID_t_data; 
input ID_use_imm, ID_use_dst_reg;
input ID_update_neg, ID_update_carry, ID_update_ov, ID_update_zero; //flag updates
input[2:0] ID_alu_opcode, ID_branch_conditions;
input[16:0] ID_imm; 
input[4:0] ID_dst_reg;

//sprite inputs
input[7:0] ID_sprite_addr;
input[3:0] ID_sprite_action;
input ID_sprite_use_imm, ID_sprite_re, ID_sprite_we, ID_sprite_use_dst_reg;
input[13:0] ID_sprite_imm;


output reg[21:0] EX_PC, EX_PC_out;
output reg[31:0] EX_instr, EX_s_data, EX_t_data; 
output reg EX_use_imm, EX_use_dst_reg;
output reg EX_update_neg, EX_update_carry, EX_update_ov, EX_update_zero; //flag updates
output reg[2:0] EX_alu_opcode, EX_branch_conditions;
output reg[16:0] EX_imm; 
output reg[4:0] EX_dst_reg;

//sprite outputs
output reg[7:0] EX_sprite_addr;
output reg[3:0] EX_sprite_action;
output reg EX_sprite_use_imm, EX_sprite_re, EX_sprite_we, EX_sprite_use_dst_reg;
output reg[13:0] EX_sprite_imm;

always @(posedge clk, negedge rst_n)
	if (!rst_n) begin
	 EX_PC <= 0;
 	 EX_PC_out <= 0;
 	 EX_instr <= 0;
 	 EX_s_data <= 0;
 	 EX_t_data <= 0;
 	 EX_use_imm <= 0;
	 EX_use_dst_reg <= 0;
 	 EX_update_neg <= 0;
 	 EX_update_carry <= 0;
 	 EX_update_ov <= 0;
 	 EX_update_zero <= 0;
 	 EX_alu_opcode <= 0;
 	 EX_branch_conditions <= 0;
	 EX_imm <= 0;
	 EX_dst_reg <= 0;
	 EX_sprite_addr <= 0;
	 EX_sprite_action <= 0;
	 EX_sprite_use_imm <= 0;
	 EX_sprite_re <= 0;
	 EX_sprite_we <= 0;
	 EX_sprite_use_dst_reg <= 0;
	 EX_sprite_imm <= 0;
	end
	else if (flush) begin
	 EX_PC <= 0;
 	 EX_PC_out <= 0;
 	 EX_instr <= 0;
 	 EX_s_data <= 0;
 	 EX_t_data <= 0;
 	 EX_use_imm <= 0;
	 EX_use_dst_reg <= 0;
 	 EX_update_neg <= 0;
 	 EX_update_carry <= 0;
 	 EX_update_ov <= 0;
 	 EX_update_zero <= 0;
 	 EX_alu_opcode <= 0;
 	 EX_branch_conditions <= 0;
	 EX_imm <= 0;
	 EX_dst_reg <= 0;
	 EX_sprite_addr <= 0;
	 EX_sprite_action <= 0;
	 EX_sprite_use_imm <= 0;
	 EX_sprite_re <= 0;
	 EX_sprite_we <= 0;
	 EX_sprite_use_dst_reg <= 0;
	 EX_sprite_imm <= 0;
	end
	else if (!stall & !hlt) begin
	 EX_PC <= ID_PC;
 	 EX_PC_out <= ID_PC_out;
 	 EX_instr <= ID_instr;
 	 EX_s_data <= ID_s_data;
 	 EX_t_data <= ID_t_data;
 	 EX_use_imm <= ID_use_imm;
	 EX_use_dst_reg <= ID_use_dst_reg;
 	 EX_update_neg <= ID_update_neg;
 	 EX_update_carry <= ID_update_carry;
 	 EX_update_ov <= ID_update_ov;
 	 EX_update_zero <= ID_update_zero;
 	 EX_alu_opcode <= ID_alu_opcode;
 	 EX_branch_conditions <= ID_branch_conditions;
	 EX_imm <= ID_imm;
	 EX_dst_reg <= ID_dst_reg;
	 EX_sprite_addr <= ID_sprite_addr;
	 EX_sprite_action <= ID_sprite_action;
	 EX_sprite_use_imm <= ID_sprite_use_imm;
	 EX_sprite_re <= ID_sprite_re;
	 EX_sprite_we <= ID_sprite_we;
	 EX_sprite_use_dst_reg <= ID_sprite_use_dst_reg;
	 EX_sprite_imm <= ID_sprite_imm;
	end


endmodule 
