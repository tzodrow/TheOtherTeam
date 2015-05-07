module id(
		input clk,
		input rst,
		input [31:0] instr,
		output [4:0] reg1_addr,
		output [4:0] reg2_addr,
		output [4:0] dst_reg,
		output reg pc_reg_sel, // Select the Register data as the PC
		output reg pc_immd_sel, // Select the Immediate data as the PC
		output reg alu_immd_sel, // Select the Immediate Value in the ALU
		output reg mem_we, // Write Enable signal for the write to Memory
		output reg wb_mem_sel, // Select to write back the data from the Memory instead of ALU
		output reg wb_pc_sel, // Select to write back the data from the PC instead of ALU
		output reg wb_we, // Write Enable signal for the WB to Register File
		output reg wb_mov_sel, // Select to write back the data from move instructions
		output reg hlt_out,
		output [1:0] mov_byte_sel, // Select for which byte is written on a MOVi
		output [7:0] mov_byte,
		output reg [2:0] alu_op,
		output [16:0] alu_immd,
		output [21:0] pc_immd);
	
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
	
	localparam JAL_REG = 5'd31;
	
	reg save_jal;
	
	assign reg1_addr = (save_jal) ? JAL_REG : instr[21:17];
	assign reg2_addr = (mem_we) ? instr[26:22] : instr[16:12];
	
	assign dst_reg = instr[26:22];
	
	assign alu_immd = instr[16:0];
	
	assign mov_byte_sel = instr[21:20];
	assign mov_byte = instr[7:0];
	
	assign pc_immd = instr[21:0];
	
	always @ (*) begin
		alu_op = ALU_ADD;
		alu_immd_sel = 0;
		wb_mem_sel = 0;
		mem_we = 0;
		wb_we = 0;
		wb_mov_sel = 0;
		wb_pc_sel = 0;
		pc_reg_sel = 0;
		pc_immd_sel = 0;
		hlt_out = 0;
		save_jal = 0;
		
		case(instr[31:27])
			ADD : begin
				alu_op = ALU_ADD;
				wb_we = 1;
			end
			ADDi : begin
				alu_op = ALU_ADD;
				alu_immd_sel = 1;
				wb_we = 1;
			end
			SUB : begin
				alu_op = ALU_SUB;
				wb_we = 1;
			end
			SUBi : begin
				alu_op = ALU_SUB;
				alu_immd_sel = 1;
				wb_we = 1;
			end
			LW : begin
				alu_op = ALU_ADD;
				alu_immd_sel = 1;
				wb_mem_sel = 1;
				wb_we = 1;
			end
			SW : begin
				alu_op = ALU_ADD;
				alu_immd_sel = 1;
				mem_we = 1;
			end
			MOV : begin
				alu_op = ALU_ADD;
				alu_immd_sel = 1;
				wb_we = 1;
			end
			MOVi : begin
				wb_mov_sel = 1;
				wb_we = 1;
			end
			AND : begin
				alu_op = ALU_AND;
				wb_we = 1;
			end
			OR : begin
				alu_op = ALU_OR;
				wb_we = 1;
			end
			NOR : begin
				alu_op = ALU_NOR;
				wb_we = 1;
			end
			SLL : begin
				alu_op = ALU_SLL;
				wb_we = 1;
			end
			SRL : begin
				alu_op = ALU_SRL;
				wb_we = 1;
			end
			SRA : begin
				alu_op = ALU_SRA;
				wb_we = 1;
			end
			B : begin
				// TODO
				pc_immd_sel = 1;
			end
			JR : begin
				pc_reg_sel = 1;
			end
			JAL : begin
				save_jal = 1;
				pc_immd_sel = 1;
				wb_pc_sel = 1;
				wb_we = 1;
			end
			HALT : begin
				hlt_out = 1;
			end
			// TODO Sprite Instructions
			
		endcase
	end
endmodule