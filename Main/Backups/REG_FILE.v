`timescale 1ns / 1ps
module REG_FILE (
			input clka, // input clka
			input wea, // input [0 : 0] wea
			input [4:0] addra, // input [4 : 0] addra
			input [31:0] dina, // input [31 : 0] dina
			input clkb, // input clkb
			input rstb, // input rstb
			input [4:0] addrb, // input [4 : 0] addrb
			output reg [31:0] doutb // output [31 : 0] doutb
		);

	reg [31:0] register [0:2**5-1];

	initial begin
		$readmemb("reg_mem.hex", register);
	end

	always @ (posedge clka, posedge rstb) begin
		if(rstb)
			register[0] <= 0;
		else if(wea)
			register[addra] <= dina;
	end

	always @ (negedge clka, posedge rstb) begin
		if(rstb)
			doutb <= 0;
		else 
			doutb <= register[addrb];
	end

endmodule