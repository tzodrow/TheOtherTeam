module sprite_addr(address, coordinates, counter);
	input [16:0] coordinates;
	input [5:0] counter;
	output reg [16:0] address;

	always@(*) begin
		address = 0;
		if(counter < 8) address = coordinates + counter;
		else if(counter < 16) address = coordinates + 320*1 + counter - 8;
		else if(counter < 24) address = coordinates + 320*2 + counter - 16;
		else if(counter < 32) address = coordinates + 320*3 + counter - 24;
		else if(counter < 40) address = coordinates + 320*4 + counter - 32;
		else if(counter < 48) address = coordinates + 320*5 + counter - 40;
		else if(counter < 56) address = coordinates + 320*6 + counter - 48;
		else 				  address = coordinates + 320*7 + counter - 56;
	end

endmodule