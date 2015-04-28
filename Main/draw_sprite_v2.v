module draw_sprite(
		input clk,
		input rst_n,
		input start,
		input [16:0] data_in,
		input [7:0] addr_in,
		output [16:0] frame_addr,
		output [23:0] frame_data,
		output [13:0] img_mem_addr,
		input [23:0] img_pixel_data,
		output reg rdy
	);
	
	localparam IDLE = 2'b00;
	localparam WRITE_FRAME = 2'b01;
	
	reg [1:0] state, nxt_state;
	reg [16:0] coordinates;
	reg ld_data, rst_counter;
	reg [7:0] img_addr;
	reg [5:0] counter;
	
	assign img_mem_addr = {img_addr, counter};
	assign frame_addr = coordinates + counter[2:0] + 320 * counter[5:3];
	assign frame_data = img_pixel_data;
	
	always @ (posedge clk, negedge rst_n)
		if(!rst_n)
			counter <= 0;
		else if (rst_counter)
			counter <= 0;
		else
			counter <= counter + 1;
	
	always @ (posedge clk, negedge rst_n)
		if(!rst_n)
			state <= 0;
		else
			state <= nxt_state;
		
	always @ (posedge clk, negedge rst_n)
		if(!rst_n) begin
			coordinates <= 0;
			img_addr <= 0;
		end
		else if(ld_data) begin
			coordinates <= data_in;
			img_addr <= addr_in;
		end
		
	always @ (*) begin
		rdy = 0;
		ld_data = 0;
		rst_counter = 0;
		nxt_state = IDLE;
		case(state)
			IDLE : begin
				rdy = 1;
				if(start) begin
					nxt_state = WRITE_FRAME;
					ld_data = 1;
					rst_counter = 1;
				end
			end
			WRITE_FRAME : begin
				if(~&counter)
					nxt_state = WRITE_FRAME;
			end
		endcase
	end
	
endmodule