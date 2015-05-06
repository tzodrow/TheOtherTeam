`timescale 1ns / 1ps
module instr_fetch(
		input clk,
		input rst_n,
		input hlt,
		input stall,
		input [21:0] addr,
		output [31:0] instr
		);
	
	localparam HALT = 32'hf800000000000000;
	
	instr_mem INSTR_MEM (
	  .clka(clk), // input clka
	  .ena(~stall & (~halt | ~rst_n)), // input ena
	  .addra(addr[6:0]), // input [6 : 0] addra
	  .douta(instr) // output [31 : 0] douta
	);
	
endmodule
