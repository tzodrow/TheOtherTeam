module draw_map(
		input clk,
		input rst_n,
		input start,
		output reg done,
		input [31:0] pixel,
		input mem_rdy,
		input [18:0] base_addr,
		output reg mem_re,
		output reg [18:0] addr, // Same for both Map Memory and Frame buffer (Maybe)
		input frame_rdy,
		output reg frame_we,
		output reg [31:0] frame_data
		);
	
	localparam IDLE = 2'b00;
	localparam READ_MEM_PIXEL = 2'b01;
	localparam WRITE_FRAME_BUFFER = 2'b10;
	localparam INC_ADDR = 2'b11;
	
	localparam HEX_3072000 = 19'h4B000 - 1; // 307,200 = 480 x 640
	
	reg [1:0] state, nxt_state;
	reg ld_addr, inc_addr, ld_frame_data;
	reg inc_counter, rst_counter;
	reg [17:0] counter;
	
	always @ (posedge clk, negedge rst_n)
		if(!rst_n)
			state <= 0;
		else
			state <= nxt_state;
		
	always @ (posedge clk, negedge rst_n)
		if(!rst_n)
			addr <= 0;
		else if(ld_addr)
			addr <= base_addr;
		else if(inc_addr)
			addr <= addr + 1;
		
	always @ (posedge clk, negedge rst_n)
		if(!rst_n)
			frame_data <= 0;
		else if(ld_frame_data)
			frame_data <= pixel;
		
	always @ (posedge clk, negedge rst_n)
		if(!rst_n)
			counter <= 0;
		else if(rst_counter)
			counter <= 0;
		else if(inc_counter)
			counter <= counter + 1;
		
	always @ (*) begin
		ld_addr = 0;
		inc_addr = 0;
		ld_frame_data = 0;
		done = 0;
		mem_re = 0;
		frame_we = 0;
		nxt_state = IDLE;
		inc_counter = 0;
		rst_counter = 0;
		
		case(state)
			IDLE : begin
				if(start) begin
					ld_addr = 1;
					rst_counter = 1;
					nxt_state = READ_MEM_PIXEL;
				end
			end
			READ_MEM_PIXEL : begin
				if(!mem_rdy) begin
					nxt_state = READ_MEM_PIXEL;
				end
				else begin
					nxt_state = WRITE_FRAME_BUFFER;
					mem_re = 1;
					ld_frame_data = 1;
				end
			end
			WRITE_FRAME_BUFFER : begin
				if(!frame_rdy) begin
					nxt_state = WRITE_FRAME_BUFFER;
				end
				else begin
					nxt_state = READ_MEM_PIXEL;
					frame_we = 1;
					inc_addr = 1;
					inc_counter = 1;
					if(counter == HEX_3072000) begin
						nxt_state = IDLE;
					end
					else begin
						nxt_state = READ_MEM_PIXEL;
					end
				end
			end
		endcase
	end
	
endmodule