module instr_decode(clk,rst_n,instr, alu_opcode, imm, regS_data_ID, regT_data_ID, use_imm,
	  use_dst_reg, is_branch_instr, update_neg, update_carry, update_overflow, update_zero, sprite_addr, 
	  sprite_action, sprite_use_imm, sprite_imm, /*sprite_reg_data,*/ sprite_re, sprite_we, sprite_use_dst_reg, IOR, dst_reg, hlt,
	  PC_in, PC_out, dst_reg_WB, dst_reg_data_WB, we, branch_addr, branch_conditions, mem_alu_select, mem_we, mem_re, use_sprite_mem);

input clk,rst_n;
input [31:0]instr;
input [21:0] PC_in;
//input [31:0]regS_data, regT_data; //reg data from the reg file

input [4:0]dst_reg_WB; //from WB
input [31:0]dst_reg_data_WB; //from WB
input we; //from WB

output logic hlt;

output [2:0] branch_conditions; //conditional code for branch instructions
output logic is_branch_instr; //sent to branch predictor to tell if a branch instr is decoded
output [21:0] branch_addr; //New PC addr from a branch instr
output logic update_neg, update_carry, update_overflow, update_zero; //control signals for EX to determine which flags to update 

output logic [2:0]alu_opcode; //to pipleine reg for EX stage\
output [16:0]imm; //to branch predictor and ID/EX pipeline reg
output [31:0]regS_data_ID, regT_data_ID; //reg data from the register file
output [21:0] PC_out; //PC simply passed along the pipeline
output [4:0] dst_reg; //sent down the pipeline for WB
output logic use_imm; //asserted for any instruction which uses immediate values
output logic use_dst_reg; //asserted if a destination reg is used
output logic mem_alu_select; 
output logic mem_we, mem_re;

output [7:0]sprite_addr; //tells EX which sprite it's accessing
output [3:0]sprite_action;
output sprite_use_imm;
output [13:0]sprite_imm;
//output [31:0]sprite_reg_data;
output logic sprite_re, sprite_we, sprite_use_dst_reg;
output logic IOR;//read signal for spart
output logic use_sprite_mem;

logic reT, reS; //Reg read enable signals sent to the reg file
wire [4:0]regS_addr, regT_addr; //to the reg file 
reg_file iRF(.clk(clk),.regS(regS_addr),.regT(regT_addr),.p0(regS_data_ID),.p1(regT_data_ID),.reS(reS),.reT(reT),.dst_reg_WB(dst_reg_WB),.dst_reg_data_WB(dst_reg_data_WB),.we(we),.hlt(hlt));


localparam ADD = 5'b00000;
localparam ADDi = 5'b00001;
localparam SUB = 5'b00010;
localparam SUBi = 5'b00011;
localparam LW = 5'b00100;
localparam SW = 5'b00101;
localparam MOV = 5'b00110;
localparam MOVi = 5'b00111;
localparam AND = 5'b01000;
localparam OR = 5'b01001;
localparam NOR = 5'b01010;
localparam SLL = 5'b01011;
localparam SRL = 5'b01100;
localparam SRA = 5'b01101;
localparam B = 5'b01110;
localparam JR = 5'b10000;
localparam JAL = 5'b10001;
localparam HALT = 5'b11111;
localparam ACT = 5'b10010;
localparam LD = 5'b10011;
localparam RD = 5'b10100;
localparam MAP = 5'b10101;
localparam CORD = 5'b10110;
localparam KEY = 5'b10111;
localparam TM = 5'b11000;

localparam ALU_ADD = 3'b000;
localparam ALU_SUB = 3'b001;
localparam ALU_AND = 3'b010;
localparam ALU_OR = 3'b011;
localparam ALU_NOR = 3'b100;
localparam ALU_SLL = 3'b101;
localparam ALU_SRL = 3'b110;
localparam ALU_SRA = 3'b111;


wire [4:0] opcode;
assign PC_out = PC_in;

logic cord_instr, rd_instr, mov_instr, movi_instr, act_ld_instr; //asserted for the CORD and RD gpu instructions for determining dst_reg bitfield

assign dst_reg = (cord_instr == 1) ? instr[14:10]:
		 (rd_instr == 1) ? instr[14:10]:
		 instr[26:22];

assign branch_conditions = instr[26:24];
assign branch_addr = instr[21:0];

assign sprite_action = instr[26:23];

assign regS_addr = (movi_instr == 1) ? 4'h0 : //want S to be 0 so acts like an ADDi instr
		   (act_ld_instr == 1) ?  instr[14:10]: //bitfield for source reg is different for this ACT and LD gpu instructions
		    instr[21:17];
assign regT_addr = (mov_instr == 1) ? 4'h0 :
		    instr[16:12];

assign opcode = instr[31:27];
assign imm = instr[16:0];
//assign regS_data_ID = regS_data;
//assign regT_data_ID = regT_data;

//sprite assign statements
assign sprite_addr = instr[22:15];
assign sprite_use_imm = instr[0];
assign sprite_imm = instr[14:1];

//assign sprite_reg_data = regS_data_ID;



always_comb begin
 use_imm = 0;
 use_dst_reg = 0;
 reT = 0;
 reS = 0;
 hlt = 0;
 cord_instr = 0;
 rd_instr = 0;
 movi_instr = 0;
 mov_instr = 0;
 act_ld_instr = 0;
 //update_sign = 0; 
 update_neg = 0; 
 update_carry = 0; 
 update_overflow = 0; 
 update_zero = 0;
 use_sprite_mem = 0;
 
 mem_alu_select = 0; 
 mem_we = 0;
 mem_re = 0;
 //use_alu = 0;

 sprite_re = 0;
 sprite_we = 0;
 sprite_use_dst_reg = 0;

 alu_opcode = 0;
 is_branch_instr = 0;

 IOR = 0;

  case (opcode)
   ADD : begin
 	reT = 1;
 	reS = 1;
	use_dst_reg = 1;
	//update_sign = 1; 
 	update_neg = 1; 
 	update_carry = 1; 
 	update_overflow = 1; 
 	update_zero = 1;
	alu_opcode = ALU_ADD;
	//use_alu = 1;
	end

	ADDi : begin
 	reS = 1;
	use_imm = 1;
	use_dst_reg = 1;
	//update_sign = 1; 
 	update_neg = 1; 
 	update_carry = 1; 
 	update_overflow = 1; 
 	update_zero = 1;
	alu_opcode = ALU_ADD;
	//use_alu = 1;
	end

	SUB : begin
 	reT = 1;
 	reS = 1;
  	use_dst_reg = 1;
	//update_sign = 1; 
 	update_neg = 1; 
 	update_carry = 1; 
 	update_overflow = 1; 
 	update_zero = 1;
	alu_opcode = ALU_SUB;
	//use_alu = 1;
	end

	SUBi : begin 
 	reS = 1;
	use_dst_reg = 1;
	use_imm = 1;
	//update_sign = 1; 
 	update_neg = 1; 
 	update_carry = 1; 
 	update_overflow = 1; 
 	update_zero = 1;
	alu_opcode = ALU_SUB;   //CHECK
	//use_alu = 1;
	end

	LW : begin
 	reS = 1;
   mem_re = 1;
 	mem_alu_select = 1;
	use_dst_reg = 1;
	end	
	
	SW : begin
 	reS = 1;
 	mem_we = 1;
	end

	MOV : begin
 	reS = 1;
	use_dst_reg = 1;
	mov_instr = 1;
	end	

	MOVi : begin
 	reS = 1;
	use_dst_reg = 1;
	use_imm = 1;
	movi_instr = 1;
	end

	AND : begin
 	reT = 1;
 	reS = 1;
	use_dst_reg = 1; 
 	update_zero = 1;
	alu_opcode = ALU_AND;
	//use_alu = 1;
	end

	OR : begin
 	reT = 1;
 	reS = 1;
	use_dst_reg = 1;
	update_zero = 1;
	alu_opcode = ALU_OR;
	//use_alu = 1;
	end

	NOR : begin
 	reT = 1;
 	reS = 1;
	use_dst_reg = 1;
	update_zero = 1;
	alu_opcode = ALU_NOR;
	//use_alu = 1;
	end

	SLL : begin
 	reS = 1;
	use_dst_reg = 1;
	use_imm = 1;
	update_zero = 1;
	update_overflow = 1; //not sure
	alu_opcode = ALU_SLL;
	//use_alu = 1;
	end

	SRL : begin
 	reS = 1;
	use_dst_reg = 1;
	use_imm = 1;
	update_zero = 1;
	alu_opcode = ALU_SRL;
	//use_alu = 1;
	end

	SRA : begin
 	reS = 1;
	use_dst_reg = 1;
	use_imm = 1;
	update_zero = 1;
	alu_opcode = ALU_SRA;
	//use_alu = 1;
	end

	B : begin
	use_imm = 1;
	is_branch_instr = 1;
	end

	JR : begin
 	reS = 1;
	is_branch_instr = 1;
	end

	JAL : begin
	use_dst_reg = 1;
	use_imm = 1;
	is_branch_instr = 1;
	end

	HALT : begin
	hlt = 1;
	end

	ACT : begin
	sprite_we = 1;
	act_ld_instr = 1;
	end

	LD : begin
	sprite_we = 1;
	act_ld_instr = 1;
	end

	RD : begin
	sprite_re = 1;
	sprite_use_dst_reg = 1;
	rd_instr = 1;
	use_sprite_mem = 1;
	end

	MAP : begin
	sprite_we = 1;
	end

	CORD : begin
	sprite_re = 1;
	sprite_use_dst_reg = 1;
	cord_instr = 1;
	use_sprite_mem = 1;
	end

	KEY : begin
	IOR = 1;
	end

	TM : begin
	sprite_we = 1;
	end


  endcase
end

endmodule
  
  
