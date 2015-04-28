module spu_controller(
		input clk,
		input rst_n,
		input counter_done,
		input draw_map_done,
		input move_logic_done,
		output reg draw_map_start,
		output reg move_logic_start,
		output reg draw_map_en,
		output reg move_logic_en
		);

	localparam IDLE = 2'b00;
	localparam DRAW_MAP = 2'b01;
	localparam DRAW_SPRITE = 2'b10;
	
	reg [1:0] state, nxt_state;
	
	always @ (posedge clk, negedge rst_n)
		if(!rst_n)
			state <= 0;
		else
			state <= nxt_state;
		
	always @ (*) begin
		draw_map_start = 0;
		move_logic_start = 0;
		draw_map_en = 0;
		move_logic_en = 0;
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
					move_logic_start = 1;
				end
				else begin
					nxt_state = DRAW_MAP;
					draw_map_en = 1;
				end
			end
			DRAW_SPRITE : begin
				if(move_logic_done) begin
					nxt_state = IDLE;
				end
				else begin
					nxt_state = DRAW_SPRITE;
					move_logic_en = 1;
				end
			end
		endcase
	end			

endmodule

