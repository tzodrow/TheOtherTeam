module draw_map_tb();
	
	reg [31:0] stm_pixel;
	reg [18:0] stm_base_addr;
	reg stm_clk, stm_rst_n, stm_start, stm_mem_rdy, stm_frame_rdy;
	wire [31:0] frame_data_mon;
	wire [18:0] addr_mon;
	wire done_mon, mem_re_mon, frame_we_mon, frame_data_mon;
	
	draw_map dm0(
		.clk(stm_clk),
		.rst_n(stm_rst_n),
		.start(stm_start),
		.done(done_mon),
		.pixel(stm_pixel),
		.mem_rdy(stm_mem_rdy),
		.base_addr(stm_base_addr),
		.mem_re(mem_re_mon),
		.addr(addr_mon), // Same for both Map Memory and Frame buffer (Maybe)
		.frame_rdy(stm_frame_rdy),
		.frame_we(frame_we_mon),
		.frame_data(frame_data_mon)
		);
	
	always
		#5 stm_clk <= ~stm_clk;
		
	initial begin
		stm_rst = 1;
		stm_clk = 0;
		stm_start = 0;
		stm_base_addr = 0;
		stm_mem_rdy = 0;
		stm_pixel = 0;
		stm_mem_rdy = 0;
		stm_frame_rdy = 0;
		
		repeat(2) @ (posedge stm_clk);
		stm_rst = 0;
		
		@(posedge stm_clk);
		stm_start = 1;
		stm_base_addr = 0;
		
		@(posedge stm_clk);
		stm_start = 0;
		
		while(addr_mon != (stm_base_addr + 307200 - 1)) begin
			@(posedge stm_clk);
			stm_mem_rdy = 1;
			stm_pixel = stm_pixel + 8;
			
			@(negedge stm_clk);
			if(!mem_re_mon) begin
				$display("Memory was not read");
				$stop();
			end
			
			@(posedge stm_clk);
			stm_mem_rdy = 0;
			stm_frame_rdy = 1;
			
			@(negedge stm_clk);
			if(!frame_we_mon) begin
				$display("Frame was not written");
				$stop();
			end
			if(stm_pixel != frame_data_mon) begin
				$display("Frame did not receive the correct data");
				$stop();
			end
			
		end
	end
	
endmodule