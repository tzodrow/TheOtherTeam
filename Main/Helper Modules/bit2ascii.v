module bit2ascii(
		input val,
		output reg [7:0] ascii);
	
	always @ (val) begin
		ascii = (val) ? 8'h31 : 8'h30;
	end
endmodule