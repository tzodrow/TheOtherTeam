module draw_sprite(clk, rst_n, write_en, frame_addr, frame_data, rom_addr, read_en, done, coordinates, img_sel, move, start, rom_data);
	
	input clk;
	input rst_n

	// Move Logic inputs/outputs
	input [18:0] coordinates;
	input [7:0] img_sel;
	input start;
	output reg done;

	// Frame buffer outputs
	output [18:0] frame_addr;
	output [23:0] frame_data;
	output write_en;

	// Sprite Image Memory (ROM) input/outputs
	input [31:0] rom_data;
	output [7:0] rom_addr;
	output read_en;

	reg [1:0] state, next_state;
reg 
	localparam IDLE = 2'b00;
	localparam READ = 2'b01;
	localparam WRITE = 2'b10;
	localparam INC_ADDR = 2'b11;

	always@(posedge clk, negedge rst_n) begin
		if(!rst_n) state <= IDLE;
		else state <= next_state;
	end

	always @(*) begin
		next_state = IDLE;
		done = 0;
	end


endmodule