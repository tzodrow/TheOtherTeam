module spu_controller_tb();
	
	reg stm_clk, stm_rst_n, stm_counter_done, stm_draw_map_done,
		stm_draw_sprite_done, stm_draw_score_done;
	wire draw_map_start_mon, draw_sprite_start_mon, draw_score_start_mon;
	
	spu_controller spu0(
		.clk(stm_clk),
		.rst_n(stm_rst_n),
		.counter_done(stm_counter_done),
		.draw_map_done(stm_draw_map_done),
		.draw_sprite_done(stm_draw_sprite_done),
		.draw_score_done(stm_draw_score_done),
		.draw_map_start(draw_map_start_mon),
		.draw_sprite_start(draw_sprite_start_mon),
		.draw_score_start(draw_score_start_mon));
	
	always
		#5 stm_clk <= ~stm_clk;
	
	initial begin
		stm_clk = 0;
		stm_rst_n = 0;
		stm_counter_done = 0;
		stm_draw_map_done = 0;
		stm_draw_sprite_done = 0;
		stm_draw_score_done = 0;
		
		@(posedge stm_clk);
		stm_rst_n = 1;
		
		repeat(2)@(posedge stm_clk);
		stm_counter_done = 1;
		
		@(posedge stm_clk);
		stm_counter_done = 0;
		
		if(!draw_map_start_mon) begin
			$display("Error: Draw Map Start not asserted");
			$stop();
		end
		
		repeat(5)@(posedge stm_clk);
		stm_draw_map_done = 1;
		
		@(posedge stm_clk);
		stm_draw_map_done = 0;
		
		if(!draw_sprite_start_mon) begin
			$display("Error: Draw Sprite Start not asserted");
			$stop();
		end
		
		repeat(5)@(posedge stm_clk);
		stm_draw_sprite_done = 1;
		
		@(posedge stm_clk);
		stm_draw_sprite_done = 0;
		
		if(!draw_score_start_mon) begin
			$display("Error: Draw Score Start not asserted");
			$stop();
		end
	end
		
		

	
endmodule

