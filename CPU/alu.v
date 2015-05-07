module alu(
		input clk,
		input rst,
		input immd_sel,
		input [31:0] reg1_data,
		input [31:0] reg2_data,
		input [16:0] immd,
		input [2:0] op,
		output [31:0] data_out);
	
	localparam ADD = 3'b000;
	localparam SUB = 3'b001;
	localparam AND = 3'b010;
	localparam OR = 3'b011;
	localparam NOR = 3'b100;
	localparam SLL = 3'b101;
	localparam SRL = 3'b110;
	localparam SRA = 3'b111;
	
	wire [31:0] src0, src1;
	
	assign src0 = reg1_data;
	assign src1 = (immd_sel) ? {{15{1'b0}}, immd} : reg2_data;
	
	assign data_out = (op == ADD) ? src0 + src1 : 
						(op == SUB) ? src0 - src1 :
						(op == AND) ? src0 & src1 :
						(op == OR) ? src0 | src1 :
						(op == NOR) ? ~(src0 | src1) :
						(op == SLL) ? src0 << src1 :
						(op == SRL) ? src0 >> src1 :
						(op == SRA) ? $signed(src0) >>> imm[4:0] : 0;
	
endmodule