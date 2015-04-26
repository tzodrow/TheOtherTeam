module ms_counter(
		input clk, // 100 MHz Clock
		input rst_n,
		output counter_done
		);
	
	localparam ONE_HUNDRED_MS = 24'h989680;
	
	reg [23:0] counter;
	
	assign counter_done = (counter == ONE_HUNDRED_MS) ? 1 : 0;
	
	always @ (posedge clk, negedge rst_n)
		if(!rst_n)
			counter <= 0;
		else if(counter_done)
			counter <= 0;
		else
			counter <= counter + 1;
	
endmodule