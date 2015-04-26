module draw_sprite(clk, rst_n, write_en, frame_addr, frame_data, frame_write_valid, rom_addr, read_en, rom_data_valid, done, coordinates, img_sel, start, rom_data);
	
	input clk;
	input rst_n;

	// Move Logic inputs/outputs
	input [16:0] coordinates;
	reg [16:0] cord_flop;
	input [7:0] img_sel;
	reg [7:0] img_flop;
	input start;
	output reg done;

	// Frame buffer outputs
	input frame_write_valid;
	output [16:0] frame_addr;
	output [23:0] frame_data;
	output reg write_en;

	// Sprite Image Memory (ROM) input/outputs
	input [31:0] rom_data;
	input rom_data_valid;
	reg [31:0] rom_data_flop;
	output [13:0] rom_addr;
	output reg read_en;

	reg [1:0] state, next_state;
	reg [5:0] counter;
	reg increment, set_done, rst_counter;
	
	sprite_addr calc_addr(frame_addr, cord_flop, counter);

	localparam IDLE = 2'b00;
	localparam READ = 2'b01;
	localparam WRITE = 2'b10;
	localparam INC_ADDR = 2'b11;

	assign frame_data = rom_data_flop[23:0];
	assign rom_addr = {img_flop, counter};


	// flop values to protect against move logic doing stupid shit
	always @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			cord_flop <= 17'b0;
			img_flop <= 8'b0;
			rom_data_flop <= 32'b0;
		end
		else begin
			if(start) begin
				cord_flop <= coordinates;
				img_flop <= img_sel;
			end
			else begin
				cord_flop <= cord_flop;
				img_flop <= img_flop;
			end
			if(rom_data_valid) rom_data_flop <= rom_data;
			else rom_data_flop <= rom_data_flop;
		end
	end

	always @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			state <= IDLE;
			done <= 0;
		end
		else begin
			state <= next_state;
			if(set_done) done <= 1;
			else if(start) done <= 0;
			else done <= done; 
		end
	end

	always @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			counter <= 6'b0;
		else if(start || rst_counter) begin
			counter <= 6'b0;
		end
		else if(increment)
			if(counter == 6'b111111) counter <= 0;
			else counter <= counter + 1;
		else begin
			counter <= counter;
		end
	end

	always @(*) begin
		next_state = IDLE;
		set_done = 0;
		write_en = 0;
		read_en = 0;
		increment = 0;
		rst_counter = 0;
		case(state)
			IDLE: 
				begin
					if(start) next_state = READ;
				end
			READ:
				begin
					read_en = 1;
					if(rom_data_valid) begin 
						next_state = WRITE;
					end
					else next_state = READ;
				end
			WRITE:
				begin
					write_en = 1;
					if(frame_write_valid) begin
						increment = 1;
						if(counter == 6'd63) begin
							set_done = 1;
							rst_counter = 1;
							next_state = IDLE;
						end
						else next_state = READ;
					end
					else next_state = WRITE;
				end
		endcase

	end


endmodule