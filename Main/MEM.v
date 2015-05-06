`timescale 1ns / 1ps
module MEM(
	input clk, 
	input rst_n, 
	input [31:0] mem_data, 
	input [21:0] addr, 
	input re, 
	input we, 
	input [31:0] ALU_result, 
	input [31:0] sprite_data, 
	input sprite_ALU_select, 
	input mem_ALU_select, 
	input flag_ov, 
	input flag_neg, 
	input flag_zero, 
	input [2:0] branch_condition, //Inputs
	output cache_hit, 
	/* output mem_ALU_WB_select,*/ 
	output [31:0] sprite_ALU_result, 
	output [31:0] mem_result, 
	output branch_taken); //Outputs

	
	//branch opcodes
	localparam NEQ = 3'b000;
	localparam EQ = 3'b001;
	localparam GT = 3'b010;
	localparam LT = 3'b011;
	localparam GTE = 3'b100;
	localparam LTE = 3'b101;
	localparam OVFL = 3'b110;
	localparam UNCOND = 3'b111;

	
	//Simple memory 
	//mainMem mainMemory(.clk(clk),.addr(addr),.re(re),.we(we),.wrt_data(mem_data),.rd_data(mem_result));
	
	
	//This will be for the memory with cache	
	/*mainMemory mainMem(.clk(clk),.rst_n(rst_n),.data(mem_data),.addr(addr),.cmd(cmd), //Inputs
					 .result(mem_result),.cache_hit(cache_hit)); //Outputs*/
	
	
	main_mem MAIN_MEM (
	  .clka(clk), // input clka
	  .ena(1'b1), // input ena
	  .wea(we), // input [0 : 0] wea
	  .addra(addr[4:0]), // input [4 : 0] addra
	  .dina(mem_data), // input [31 : 0] dina
	  .douta(mem_result) // output [31 : 0] douta
	);
	
	assign sprite_ALU_result = (sprite_ALU_select) ?  sprite_data : ALU_result;
	
	assign mem_ALU_WB_select = mem_ALU_select;
	
	//Flag Check
	assign branch_taken = (branch_condition == NEQ) ? !flag_zero :
							(branch_condition == EQ) ? flag_zero :
							(branch_condition == GT) ? ({flag_zero, flag_neg} == 2'b00) :
							(branch_condition == LT) ? flag_neg :
							(branch_condition == GTE) ? !flag_neg :
							(branch_condition == LTE) ? (flag_neg | flag_zero) :
							(branch_condition == OVFL) ? flag_ov :
							(branch_condition == UNCOND) ? 1 : 
							0;
endmodule