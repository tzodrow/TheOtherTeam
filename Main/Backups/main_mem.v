`timescale 1ns / 1ps
module main_mem(
	  input clka, // input clka
	  input ena, // input ena
	  input wea, // input [0 : 0] wea
	  input [4:0] addra, // input [4 : 0] addra
	  input [31:0] dina, // input [31 : 0] dina
	  output reg [31:0] douta // output [31 : 0] douta
	);


	reg [31:0] register [0:2**5-1];

	initial begin
		$readmemb("reg_mem.hex", register);
	end

	always @ (posedge clka) begin
		if(wea && ena)
			register[addra] <= dina;
	end

	always @ (negedge clka) begin
		if(ena) 
			douta <= register[addra];
	end

endmodule