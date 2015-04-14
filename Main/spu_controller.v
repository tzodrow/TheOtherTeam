module spu_controller(
		input clk,
		input rst_n,
		input counter_done,
		input draw_map_done,
		input draw_sprite_done,
		input draw_score_done,
		output reg draw_map_start,
		output reg draw_sprite_start,
		output reg draw_score_start
		);

	localparam IDLE = 2'b00;
	localparam DRAW_MAP = 2'b01;
	localparam DRAW_SPRITE = 2'b10;
	localparam DRAW_SCORE = 2'b11;
	
	reg [1:0] state, nxt_state;
	
	always @ (posedge clk, negedge rst_n)
		if(!rst_n)
			state <= 0;
		else
			state <= nxt_state;
		
	always @ (*) begin
		draw_map_start = 0;
		draw_sprite_start = 0;
		draw_score_start = 0;
		nxt_state = IDLE;
		
		case(state)
			IDLE : begin
				if(counter_done) begin
					nxt_state = DRAW_MAP;
					draw_map_start = 1;
				end
			end
			DRAW_MAP : begin
				if(draw_map_done) begin
					nxt_state = DRAW_SPRITE;
					draw_sprite_start = 1;
				end
				else begin
					nxt_state = DRAW_MAP;
				end
			end
			DRAW_SPRITE : begin
				if(draw_sprite_done) begin
					nxt_state = DRAW_SCORE;
					draw_score_start = 1;
				end
				else begin
					nxt_state = DRAW_SPRITE;
				end
			end
			DRAW_SCORE : begin
				if(!draw_score_done) begin
					nxt_state = DRAW_SCORE;
				end
			end
		endcase
	end			

endmodule

