module sprite_addr(address, coordinates, counter);
	input [16:0] coordinates;
	input [5:0] counter;
	output reg [16:0] address;

	always@(*) begin
		address = 0;
		if(counter < 6'd8) address = coordinates + counter;
		else if(counter < 6'd16) address = coordinates + 320*1 + counter - 6'd8;
		else if(counter < 6'd24) address = coordinates + 320*2 + counter - 6'd16;
		else if(counter < 6'd32) address = coordinates + 320*3 + counter - 6'd24;
		else if(counter < 6'd40) address = coordinates + 320*4 + counter - 6'd32;
		else if(counter < 6'd48) address = coordinates + 320*5 + counter - 6'd40;
		else if(counter < 6'd56) address = coordinates + 320*6 + counter - 6'd48;
		else 				  address = coordinates + 320*7 + counter - 56;
	end

endmodule