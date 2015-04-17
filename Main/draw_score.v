module draw_score(clk, rst_n, start, score_data, score_valid_data, frame_rdy, //Inputs
					done, score_re, score_addr, frame_addr, frame_data, frame_we); //Outputs

		input  clk ,rst_n, start, score_valid_data, frame_rdy;
		input  [31:0] score_data;
		output reg done, score_re, frame_we;
		output [4:0] score_addr;
		output [18:0] frame_addr;
		output [31:0] frame_data;
	
		//States for state machine
		localparam IDLE = 2'b00;
		localparam READ= 2'b01;
		localparam WRITE = 2'b10;
		localparam INCADDR = 2'b11;
		
		wire all_pixels_done, all_players_done;
		reg [3:0] lives;
		reg [7:0] health;
		reg [19:0] score;
		
		reg clr_cnt, inc_cnt, inc_player_cnt;
		reg [1:0] state, nxt_state;
		reg [18:0] pixel_cnt;
		reg [2:0] player_cnt;
		
		reg [7:0] pixel_r, pixel_g, pixel_b;
		
		//State Machine
		always @(posedge clk, negedge rst_n) begin 
			if(!rst_n)
				state <= IDLE;
			else 
				state <= nxt_state;
		end
		
		//State Machine Logic
		always @(*) begin
			//Default values 
			score_re = 0;
			clr_cnt = 0;
			inc_cnt = 0;
			inc_player_cnt = 0;
			frame_we = 0;
			done = 0;
			nxt_state = IDLE;
			
			case (state)
				IDLE:begin
					if(start)begin
						score_re = 1'b1;
						clr_cnt = 1'b1;
						nxt_state = READ;
					end
					else
						nxt_state = state;
				end
				READ:begin
					if(score_valid_data)begin
						frame_we = 1'b1;
						nxt_state = WRITE;
					end
					else begin 
						nxt_state = state;
						score_re = 1'b1;
					end
				end
				WRITE: begin
					if(frame_rdy)begin
						inc_cnt = 1;
						state = INCADDR;
					end
					else begin
						nxt_state = state;
						frame_we = 1'b1;
					end
				end
				default: begin //INCADDR
					if(!all_pixels_done)begin
						frame_we = 1'b1;
						nxt_state = WRITE;
					end
					else if(all_players_done)begin
						done = 1'b1;
						nxt_state = IDLE;
					end
					else begin //all_pixels_done, !all_players_done
						inc_player_cnt = 1'b1;
						score_re = 1'b1;
					end
				end
			endcase
		end
		
		assign score_addr = player_cnt;
		assign frame_addr = pixel_cnt;
		assign all_pixels_done = (&pixel_cnt) ? 1'b1 : 1'b0;
		assign all_players_done = (&player_cnt) ? 1'b1 : 1'b0; 		
		
		//Pixel Address Counter
		always @(posedge clk, negedge rst_n) begin
			if(clr_cnt || !rst_n)
				pixel_cnt = 0;
			else if(inc_cnt)
				pixel_cnt <= pixel_cnt + 1;
			//default pixel_cnt stays the same
		end
		
		//Player Register Counter
		always @(posedge clk, negedge rst_n) begin
			if(!rst_n || clr_cnt)
				player_cnt = 0;
			else if(inc_player_cnt)
				player_cnt <= player_cnt + 1;
			//default player_cnt stays the same
		end
		
		//Data stored in the sprite register
		assign lives = score_data[32:28];
		assign health = score_data[27:20];
		assign score = score_data[19:0];
		
		assign frame_data = {pixel_r, pixel_g, pixel_b, 8'h00};
		
		//Logic for converting score data to pixels on the screen
		
		
		
		
endmodule
