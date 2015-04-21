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
	localparam READ = 2'b01;
	localparam WRITE = 2'b10;
	localparam INCADDR = 2'b11;
	
	wire all_pixels_done, all_players_done;
	wire [3:0] lives;
	wire [7:0] health;
	wire [19:0] score;
	
	reg clr_cnt, inc_cnt, inc_player_cnt;
	reg [1:0] state, nxt_state;
	reg [13:0] pixel_cnt;
	reg [2:0] player_cnt;
	
	reg [7:0] pixel_r, pixel_g, pixel_b;
	reg [8:0] pixel_x;
	reg [3:0] pixel_y;
	wire [3:0] next_pixy;
	wire [3:0] next_pixx;
	reg [3:0] curr_digit;
	wire [11:0] rom_addr;
	wire [23:0] rom_color;
	
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
					nxt_state = IDLE;
			end
			READ:begin
				if(score_valid_data)begin
					frame_we = 1'b1;
					nxt_state = WRITE;
				end
				else begin 
					nxt_state = READ;
					score_re = 1'b1;
				end
			end
			WRITE: begin
				if(frame_rdy)begin
					inc_cnt = 1;
					nxt_state = INCADDR;
				end
				else begin
					nxt_state = WRITE;
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
					nxt_state = READ;
				end
			end
		endcase
	end
	
	assign score_addr = player_cnt;
	assign frame_addr = pixel_cnt;
	assign all_pixels_done = (4800) ? 1'b1 : 1'b0;  //Only prints out a 320 x 15 square at the top of the screen
	assign all_players_done = (&player_cnt) ? 1'b1 : 1'b0; 		
	
	//Pixel Address Counter
	always @(posedge clk, negedge rst_n) begin
		if(clr_cnt || !rst_n) begin
			pixel_cnt <= 0;
			pixel_x <= 0;
			pixel_y <= 0;
		end 
		else if(inc_cnt) begin
			pixel_cnt <= pixel_cnt + 1;
			if(pixel_x == 320) begin
				pixel_x <= 0;
				pixel_y <= pixel_y + 1;
			end 
			else 
				pixel_x <= pixel_x + 1;
		end 
		//default pixel_cnt, pixel_x, and pixel_y stay the same
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
	assign lives = score_data[31:28];
	assign health = score_data[27:20];
	assign score = score_data[19:0];
	
	//Logic for drawing the score to the frame buffer
	
	assign frame_data = {pixel_r, pixel_g, pixel_b, 8'h00};

	always@(*) begin
		case(pixel_x[6:4]) 
			/*3'h0: begin
				curr_digit = score_extended[31:28];
			end
			3'h1: begin
				curr_digit = score_extended[27:24];
			end
			3'h2: begin
				curr_digit = score_extended[23:20];
			end*/
			3'h3: curr_digit = score[19:16];
			3'h4: curr_digit = score[15:12];		
			3'h5: curr_digit = score[11:8];
			3'h6: curr_digit = score[7:4];
			3'h7: curr_digit = score[3:0];
			default: curr_digit = 0;
		endcase
	end
	   
	assign next_pixy = pixel_y + 4'h1;
	assign next_pixx = pixel_x + 4'h1;
  
	assign rom_addr = {next_pixy,curr_digit,next_pixx};
	 
    simple_rom #(12,24,"numbers.mem") num_rom(clk, rom_addr, rom_color);

    always@(*) begin
		pixel_r = 8'h00;
		pixel_g = 8'h00;
		pixel_b = 8'h00;
		if(~rst_n) begin
			case(player_cnt)
				2'b00 : begin
					if(pixel_x < 80) begin
						pixel_r = rom_color[23:16];
						pixel_g = rom_color[15:8];
						pixel_b = rom_color[7:0];
					end
				end
				2'b01 : begin
					if(pixel_x < 160 && pixel_x > 80) begin
						pixel_r = rom_color[23:16];
						pixel_g = rom_color[15:8];
						pixel_b = rom_color[7:0];
					end
				end
				2'b10 : begin
					if(pixel_x < 240 && pixel_x > 160) begin
						pixel_r = rom_color[23:16];
						pixel_g = rom_color[15:8];
						pixel_b = rom_color[7:0];
					end
				end
				//Case 2'b11
				default : begin 
					if(pixel_x < 360 && pixel_x > 240) begin
						pixel_r = rom_color[23:16];
						pixel_g = rom_color[15:8];
						pixel_b = rom_color[7:0];
					end
				end
				
			endcase
		end
	 end
	 
endmodule
