`timescale 1ns / 1ps
module IF_ID_pipeline_reg(
		input clk, 
		input rst_n, 
		input hlt, 
		input stall, 
		input flush, 
		input [31:0] IF_instr, 
		input [21:0] IF_PC, 
		output reg [31:0] ID_instr, 
		output reg [21:0] ID_PC
	);

	always @(posedge clk, negedge rst_n)
		if (!rst_n)
		  ID_instr <= 0;
		else if (flush)
		  ID_instr <= 0;
		else if (!stall & !hlt)
		  ID_instr <= IF_instr;
		else
		  ID_instr <= ID_instr;
	
	always @(posedge clk, negedge rst_n)
		if (!rst_n)
		  ID_PC <= 0;
		else if (flush)
		  ID_PC <= 0;
		else if (!stall & !hlt)
		  ID_PC <= IF_PC;
		else 
		  ID_PC <= ID_PC;

endmodule 