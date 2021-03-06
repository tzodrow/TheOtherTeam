`timescale 1ns / 1ps
module instr_decode(
	input clk,
	input rst_n,
	input [31:0] instr, 
	output reg [2:0] alu_opcode, 
	output [16:0] imm, 
	// output [31:0] regS_data_ID, 
	// output [31:0] regT_data_ID, 
	output reg use_imm,
	output reg use_dst_reg, 
	output reg is_branch_instr, 
	output reg update_neg, 
	output reg update_carry, 
	output reg update_overflow, 
	output reg update_zero, 
	output [7:0] sprite_addr, 
	output [3:0] sprite_action, 
	output sprite_use_imm, 
	output [13:0] sprite_imm, 
	/*sprite_reg_data,*/ 
	output reg sprite_re, 
	output reg sprite_we, 
	output reg sprite_use_dst_reg, 
	output reg IOR, 
	output [4:0] dst_reg, 
	output reg hlt,
	input [21:0] PC_in, 
	output [21:0] PC_out, 
	input [4:0] dst_reg_WB, 
	input [31:0] dst_reg_data_WB, 
	input we, 
	output [21:0] branch_addr, 
	output [2:0] branch_conditions, 
	output reg mem_alu_select, 
	output reg mem_we, 
	output reg mem_re, 
	output reg use_sprite_mem,
	output reg [21:0] return_PC_addr_reg, 
	input [21:0] next_PC, 
	input re_hlt, 
	input [4:0] addr_hlt, 
	output [4:0] regS_addr, 
	output [4:0] regT_addr, 
	input EX_ov, 
	input EX_neg, 
	input EX_zero);

reg reT, reS; //Reg read enable signals sent to the reg file
reg sw_instr;
reg jr_instr, jal_instr;

/*
//reg A is port S, B is port T 
register_file_S regS (
  .clka(clk), // input clka
  .ena(1'b1), // input ena
  .wea(1'b0), // input [0 : 0] wea
  .addra(regS_addr), // input [4 : 0] addra
  .dina(32'b0), // input [31 : 0] dina
  .douta(regS_data_ID), // output [31 : 0] douta
  .clkb(clk),// input clkb
  .web(we), // input [0 : 0] web
  .addrb(dst_reg_WB), // input [4 : 0] addrb
  .dinb(data_in), // input [31 : 0] dinb
  .doutb() // output [31 : 0] doutb
);

///// CHECK THIS 				/////
///// DOES THIS MAKE SENSE ??? 	/////

register_file_T regT (
  .clka(clk), // input clka
  .wea(we), // input [0 : 0] wea
  .addra(dst_reg_WB), // input [4 : 0] addra
  .dina(data_in), // input [31 : 0] dina
  .douta(),//(32'b0), // output [31 : 0] douta
  .clkb(clk),//(clk), // input clkb
  .enb(reT | we), // input enb
  .web(1'b0), // input [0 : 0] web
  .addrb(regT_addr), // input [4 : 0] addrb
  .dinb(32'b0), // input [31 : 0] dinb
  .doutb(regT_data_ID) // output [31 : 0] doutb
);
*/


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

localparam NEQ = 3'b000;
localparam EQ = 3'b001;
localparam GT = 3'b010;
localparam LT = 3'b011;
localparam GTE = 3'b100;
localparam LTE = 3'b101;
localparam OVFL = 3'b110;
localparam UNCOND = 3'b111;

always  @(posedge clk, negedge rst_n) begin
	if(!rst_n)
			return_PC_addr_reg <= 22'd0;
	else if (jal_instr)
			return_PC_addr_reg <= next_PC;
end
	
	
wire [4:0] opcode;
assign PC_out = PC_in;

reg cord_instr, rd_instr, mov_instr, movi_instr, act_ld_instr; //asserted for the CORD and RD gpu instructions for determining dst_reg bitfield

assign dst_reg = (cord_instr == 1) ? instr[14:10] :
						(rd_instr == 1) ? instr[14:10] : instr[26:22];

assign branch_conditions = instr[26:24];

// TODO: Fix this -- JR read from reg file and is delayed 1 clk
assign branch_addr = (jr_instr && (instr[26:22] == 5'h1D)) ? return_PC_addr_reg : //if reg 29 is being accessed for a JR, then it's to return from a JAL instr
							(jr_instr) 	 								  ? 22'h0 : //else it's just a normal JR
																				 instr[21:0];			 //defaults to the LABEL field for JAL/branch instrs


assign sprite_action = instr[26:23];

assign regS_addr = (hlt | re_hlt) ? addr_hlt :
			(movi_instr) ? 5'h00 : //want S to be 0 so acts like an ADDi instr
		   (act_ld_instr) ?  instr[14:10]: //bitfield for source reg is different for this ACT and LD gpu instructions
			(jr_instr) ? instr[26:22] :	
		    instr[21:17];
			 
assign regT_addr = (mov_instr == 1) ? 5'h00 :
		   (sw_instr == 1) ? instr[26:22] : 
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



always @(*) begin
	use_imm = 0;
	use_dst_reg = 0;
	reT = 0;
	reS = 0;
	hlt = 0;
	cord_instr = 0;
	rd_instr = 0;
	movi_instr = 0;
	sw_instr = 0;
	jr_instr = 0;
	jal_instr = 0;
	mov_instr = 0;
	act_ld_instr = 0;
	update_neg = 0; 
	update_carry = 0; 
	update_overflow = 0; 
	update_zero = 0;
	use_sprite_mem = 0;
 
	mem_alu_select = 0; 
	mem_we = 0;
	mem_re = 0;

	sprite_re = 0;
	sprite_we = 0;
	sprite_use_dst_reg = 0;

	alu_opcode = 3'b000;
	is_branch_instr = 0;

	IOR = 0;

	case (opcode)
		ADD : begin
			reT = 1;
			reS = 1;
			use_dst_reg = 1;
			update_neg = 1; 
			update_carry = 1; 
			update_overflow = 1; 
			update_zero = 1;
			alu_opcode = ALU_ADD;
		end

		ADDi : begin
			// reS = 1;
			use_imm = 1;
			use_dst_reg = 1;
			update_neg = 1; 
			update_carry = 1; 
			update_overflow = 1; 
			update_zero = 1;
			alu_opcode = ALU_ADD;
		end

		SUB : begin
			reT = 1;
			reS = 1;
			use_dst_reg = 1;
			update_neg = 1; 
			update_carry = 1; 
			update_overflow = 1; 
			update_zero = 1;
			alu_opcode = ALU_SUB;
		end

		SUBi : begin 
			reS = 1;
			use_dst_reg = 1;
			use_imm = 1; 
			update_neg = 1; 
			update_carry = 1; 
			update_overflow = 1; 
			update_zero = 1;
			alu_opcode = ALU_SUB;   //CHECK
		end

		LW : begin
			reS = 1;
			mem_re = 1;
			mem_alu_select = 1;
			use_dst_reg = 1;
		end	
	
		SW : begin
			reS = 1;
			reT = 1;
			sw_instr = 1;
			use_imm = 1;
			mem_we = 1;
		end

		MOV : begin
			reS = 1;
			reT = 1;
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
		end

		SRL : begin
			reS = 1;
			use_dst_reg = 1;
			use_imm = 1;
			update_zero = 1;
			alu_opcode = ALU_SRL;
		end

		SRA : begin
			reS = 1;
			use_dst_reg = 1;
			use_imm = 1;
			update_zero = 1;
			alu_opcode = ALU_SRA;
		end

		B : begin
			case(branch_conditions)
				NEQ : begin
					if(~EX_zero)
						is_branch_instr = 1;
				end
				EQ : begin
					if(EX_zero)
						is_branch_instr = 1;
				end
				GT : begin
					if(~EX_neg & ~EX_zero) 
						is_branch_instr = 1;
				end
				LT : begin
					if(EX_neg & ~EX_zero)
						is_branch_instr = 1;
				end
				GTE : begin
					if(~EX_neg | EX_zero)
						is_branch_instr = 1;
				end
				LTE : begin
					if(EX_neg | EX_zero)
						is_branch_instr = 1;
				end
				OVFL : begin
					if(EX_ov)
						is_branch_instr = 1;
				end
				UNCOND : begin
					is_branch_instr = 1;
				end
			endcase	
			use_imm = 1;
		end

		JR : begin
			reS = 1;
			jr_instr = 1;
			is_branch_instr = 1;
		end

		JAL : begin
			use_imm = 1;
			jal_instr = 1;
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
