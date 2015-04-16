module sprite_addr(address, coordinates, counter);
	input [18:0] coordinates;
	input [5:0] counter;
	output reg [18:0] address;

	always@(*) begin
		address = 0;
		if(counter < 8) address = coordinates + counter;
		else if(counter < 16) address = coordinates + 640 + counter - 8;
		else if(counter < 24) address = coordinates + 1280 + counter - 16;
		else if(counter < 32) address = coordinates + 1920 + counter - 24;
		else if(counter < 40) address = coordinates + 2560 + counter - 32;
		else if(counter < 48) address = coordinates + 3200 + counter - 40;
		else if(counter < 56) address = coordinates + 3840 + counter - 48;
		else 				  address = coordinates + 4480 + counter - 56;
	end

endmodule