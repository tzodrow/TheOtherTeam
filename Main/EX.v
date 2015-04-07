module EX(
	input PC[31:0],
	input alu_opcode[2:0],
	input update_flag_ov,
	input update_flag_sign,
	input update_flag_zero,
	input update_flag_carry,
	input t[31:0],
	input s[31:0],
	input imm[16:0],
	input use_imm,
	input dst_reg[4:0],
	input sprite_reg[4:0],
	input sprite_fcn[3:0],
	input sprite_imm[13:0],
	input sprite_use_imm,
	input sprite_addr[7:0],
	input sprite_re,
	input sprite_we,
	input sprite_use_dst_reg,
	output rec_PC[31:0],
	output ALU_result[31:0],
	output sprite_data[31:0],
	output flag_ov,
	output flag_sign,
	output flag_zero,
	output flag_carry,
	output dst_reg[4:0]
	);
	
	localparam ALU_ADD = 3'b000;
   localparam ALU_SUB = 3'b001;
   localparam ALU_AND = 3'b010;
   localparam ALU_OR = 3'b011;
   localparam ALU_NOR = 3'b100;
   localparam ALU_SLL = 3'b101;
   localparam ALU_SRL = 3'b110;
   localparam ALU_SRA = 3'b111;
	
	wire[31:0] src1, src2; 
	wire ov, sign, zero, carry;
	
	assign src1 = s; 
	assign src2 = use_imm ? {15{imm}, imm} : t; 
	
	assign ALU_result = 
			(opcode == ALU_OP_ADD)  ? src1 + src2      :
			(opcode == ALU_OP_SUB)  ? src1 - src2      :
			(opcode == ALU_OP_AND)  ? src1 & src2      :
			(opcode == ALU_OP_OR)   ? src1 | src2      :
			(opcode == ALU_OP_NOR)  ? ~(src1 | src2)   :
			(opcode == ALU_OP_SLL)  ? src1 << src2     :
			(opcode == ALU_OP_SRL)  ? src1 >> src2     :
			(opcode == ALU_OP_SRA)  ? src1 >>> src2    : ALU_result;
			
			
	//assign ov =   
			
			
		
			
			
			
			
			
			
	
	
endmodule	
