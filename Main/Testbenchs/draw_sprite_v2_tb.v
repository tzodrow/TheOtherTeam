module draw_sprite_v2_tb();
	
	reg stm_clk, stm_rst_n, stm_start;
	reg [16:0] stm_data_in;
	reg [7:0] stm_addr_in;
	reg [23:0] stm_img_pixel_data;
	
	wire rdy_mon;
	wire [16:0] frame_addr_mon;
	wire [23:0] frame_data_mon;
	wire [13:0] img_mem_addr_mon;
	
	draw_sprite draw_sprite0(
		.clk(stm_clk),
		.rst_n(stm_rst_n),
		.start(stm_start),
		.data_in(stm_data_in),
		.addr_in(stm_addr_in),
		.frame_addr(frame_addr_mon),
		.frame_data(frame_data_mon),
		.img_mem_addr(img_mem_addr_mon),
		.img_pixel_data(stm_img_pixel_data),
		.rdy(rdy_mon)
	);
	
	always
		#5 stm_clk <= ~stm_clk;
	
	initial begin
		stm_clk = 0;
		stm_rst_n = 0;
		stm_start = 0;
		stm_data_in = 0;
		stm_addr_in = 8'h10;
		stm_img_pixel_data = 24'haabbcc;
		
		@(posedge stm_clk);
		stm_rst_n = 1;
		stm_start = 1;
		
		@(posedge stm_clk);
		stm_start = 1;
		
		@(posedge rdy_mon);
		$stop();
	end
endmodule