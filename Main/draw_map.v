module draw_map(
		input clk,
		input rst_n,
		input start,
		output reg done,
		input ready,
		input [31:0] pixel,
		input mem_rdy,
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
	
	localparam HEX_480 = 9'h1E0 - 1;
	localparam HEX_640 = 10'h280 - 1;
	
	reg [1:0] state, nxt_state;
	reg rst_addr, inc_addr, ld_frame_data;
	reg inc_h_count, rst_h_count;
	reg inc_v_count, rst_v_count;
	reg [9:0] h_count;
	reg [8:0] v_count;
	
	always @ (posedge clk, negedge rst_n)
		if(!rst_n)
			state <= 0;
		else
			state <= nxt_state;
		
	always @ (posedge clk, negedge rst_n)
		if(!rst_n)
			addr <= 0;
		else if(rst_addr)
			addr <= 0;
		else if(inc_addr)
			addr <= addr + 1;
		
	always @ (posedge clk, negedge rst_n)
		if(!rst_n)
			frame_data <= 0;
		else if(ld_frame_data)
			frame_data <= pixel;
		
	always @ (posedge clk, negedge rst_n)
		if(!rst_n)
			h_count <= 0;
		else if(rst_h_count)
			h_count <= 0;
		else if(inc_h_count)
			h_count <= h_count + 1;
	
	always @ (posedge clk, negedge rst_n)
		if(!rst_n)
			v_count <= 0;
		else if(rst_v_count)
			v_count <= 0;
		else if(inc_v_count)
			v_count <= v_count + 1;
		
	always @ (*) begin
		rst_addr = 0;
		inc_addr = 0;
		ld_frame_data = 0;
		done = 0;
		mem_re = 0;
		frame_we = 0;
		nxt_state = IDLE;
		
		case(state)
			IDLE : begin
				if(start) begin
					rst_addr = 1;
					rst_h_count = 1;
					rst_v_count = 1;
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
					if(h_count == HEX_640) begin
						if(v_count == HEX_480) begin
							nxt_state = IDLE;
						end
						inc_v_count = 1;
						rst_h_count = 1;
					end
					else begin
						inc_h_count = 1;
					end
				end
			end
		endcase
	end
	
endmodule