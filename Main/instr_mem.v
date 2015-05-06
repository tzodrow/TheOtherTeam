`timescale 1ns / 1ps
module instr_mem(
		input clka,
		input ena,
		input [6:0] addra,
		output reg [31:0] douta
		);
	
	reg [31:0] memory [0:2**6-1];
		
	initial begin
		$readmemb("instr_mem.hex", memory);
	end
	
	always @ (posedge clka)
		if(ena)
			douta <= memory[addra];
	
	
endmodule