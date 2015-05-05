module EX(
	input clk,
	input rst_n,
	input[2:0] alu_opcode,
	input update_flag_ov,
	input update_flag_neg,
	input update_flag_zero,
	input[31:0] t_data,
	input[31:0] s_data,
	input[16:0] imm,
	input use_imm,
	input[3:0] sprite_action,
	input[13:0] sprite_imm,
	input sprite_use_imm,
	input[7:0] sprite_addr,
	input sprite_re,
	input sprite_we,
	input sprite_use_dst_reg,
	output[31:0] ALU_result,
	output[31:0] sprite_data,
	output reg flag_ov,
	output reg flag_neg,
	output reg flag_zero);
	
	localparam ALU_OP_ADD = 3'b000;
   localparam ALU_OP_SUB = 3'b001;
  	localparam ALU_OP_AND = 3'b010;
  	localparam ALU_OP_OR = 3'b011;
   localparam ALU_OP_NOR = 3'b100;
   localparam ALU_OP_SLL = 3'b101;
   localparam ALU_OP_SRL = 3'b110;
   localparam ALU_OP_SRA = 3'b111;
	
	wire[7:0] sprite_write_data; 
	wire[31:0] src0, src1, src1Not, mathResult, shiftInter; 
	wire ov, neg, zero;
	
	assign src0 = s_data; 
	assign src1 = use_imm ? {{15{imm[16]}}, imm} : t_data; 
	
	//Get Bitwise NOT of SRC0 for subtraction
	assign src1Not = ~(src1);
	
	assign shiftInter = $signed(src0) >>> imm[4:0]; 	  //arithmetic shift
	
	//Do math w/ saturation
	assign mathResult =  (alu_opcode == ALU_OP_ADD)	? (src0 + src1)		:   
						                   (alu_opcode == ALU_OP_SUB)	?	(src1Not + src0 + 1)	: //carry in a 1 for subtraction and use negated src1
						                  32'b0;   

    //determines if overflow occurred based on the MSBs of src0 and src1 and the results of the intermediate math op above
	assign ov =	 (alu_opcode == ALU_OP_ADD) ? 
	                (((src0[31] == src1[31]) && (src0[31] != mathResult[31])))	? 
	                      1'b1 : 1'b0: 
	                (((src1Not[31] == src0[31]) && (src1Not[31] != mathResult[31])))	?
	                      1'b1 : 1'b0;
	                   
	assign zero = &(~ALU_result);   
	assign neg = mathResult[31] ^ ov;    
	              
	assign ALU_result = 
			(alu_opcode == ALU_OP_ADD)  ? mathResult       :
			(alu_opcode == ALU_OP_SUB)  ? mathResult       :
			(alu_opcode == ALU_OP_AND)  ? src0 & src1      :
			(alu_opcode == ALU_OP_OR)   ? src0 | src1      :
			(alu_opcode == ALU_OP_NOR)  ? ~(src0 | src1)   :
			(alu_opcode == ALU_OP_SLL)  ? src0 << src1[4:0]     :
			(alu_opcode == ALU_OP_SRL)  ? src0 >> src1[4:0]     :
			(alu_opcode == ALU_OP_SRA)  ? shiftInter    : ALU_result;
			
	//assign flag_carry = update_flag_carry ? carry : flag_carry;
	//assign flag_ov = update_flag_ov ? ov : flag_ov;
	//assign flag_zero = update_flag_zero ? zero : flag_zero;
	//assign flag_neg = update_flag_neg ? neg : flag_neg;
	always@(posedge clk, negedge rst_n) begin
   	if(!rst_n) begin    
	      flag_ov <= 1'b0;
	      flag_zero <= 1'b0;
	      flag_neg <= 1'b0;
	   end
	   else begin
	      if(update_flag_ov) flag_ov <= ov;
	      else flag_ov <= flag_ov;	         
	      if(update_flag_zero) flag_zero <= zero;
	      else flag_zero <= flag_zero;	       
	      if(update_flag_neg) flag_neg <= neg;
	      else flag_neg <= flag_neg;
	   end
	end
	//SPRITE MEM STUFF
	assign sprite_write_data = sprite_use_imm ? sprite_imm[7:0] : src0[7:0];
	
	
	//assign sprite_address = //sprite address calculation based on sprite_addr and sprite_fcn(attribute) 
	//sprite_mem(sprite_fcn, sprite_addr, sprite_write_data, sprite_re, sprite_we, sprite_data);
		
endmodule