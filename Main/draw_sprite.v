module draw_sprite(clk, rst_n, write_en, frame_addr, frame_data, rom_addr, read_en, done, coordinates, img_sel, move, start, rom_data);
	
	input clk;
	input rst_n

	// Move Logic inputs/outputs
	input [18:0] coordinates;
	reg [18:0] cord_flop;
	input [7:0] img_sel;
	reg [7:0] img_flop;
	input start;
	output reg done;

	// Frame buffer outputs
	output reg [18:0] frame_addr;
	output [23:0] frame_data;
	output reg write_en;

	// Sprite Image Memory (ROM) input/outputs
	input [31:0] rom_data;
	reg [31:0] rom_data_flop;
	output [13:0] rom_addr;
	output reg read_en;

	reg [1:0] state, next_state;
	reg [5:0] counter;
	
	localparam IDLE = 2'b00;
	localparam READ = 2'b01;
	localparam WRITE = 2'b10;
	localparam INC_ADDR = 2'b11;

	assign frame_data = rom_data[23:0];
	assign rom_addr = {img_sel, counter};

	// flop values to protect against move logic doing stupid shit
	always @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			cord_flop <= 19'b0;
			img_flop <= 8'b0;
			rom_data_flop <= 32'b0;
		end
		else begin
			cord_flop <= coordinates;
			img_flop <= img_sel;
			rom_data_flop <= rom_data;
		end
	end

	always @(posedge clk, negedge rst_n) begin
		if(!rst_n) state <= IDLE;
		else state <= next_state;
	end

	always @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			counter <= 6'b0;
		else if(start) 
			counter <= 6'b0;
		else  
			counter <= counter + 1;
	end

	always @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			read_en <= 1'b0;
		else if(counter >= 6'b111111)
			read_en <= 1'b0;
		else if(start)
			read_en <= 1'b1;
	end

	always @(*) begin
		next_state = IDLE;
		done = 0;
		write_en = 0;
		read_en = 0;

	end


endmodule