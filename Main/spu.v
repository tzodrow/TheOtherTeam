module spu(
		input clk,
		input rst_n);
	
	wire draw_map_done, draw_score_done;
	wire draw_map_start, draw_score_start;
	
	spu_controller scontrol0(
		.clk(clk), .rst_n(rst_n),
		input counter_done, // Needs to be done (count to 100 ms)
		.draw_map_done(draw_map_done),
		input draw_sprite_done(), // Need to combine with the Move Logic
		.draw_score_done(draw_score_done),
		.draw_map_start(draw_map_start),
		output reg draw_sprite_start, // Need to combine with the Move Logic
		.draw_score_start(draw_score_start)
	);
	
	draw_map dmap0(
		.clk(clk), .rst_n(rst_n),
		.start(draw_map_start),
		.done(draw_map_done),
		input [31:0] pixel, // Need Memory
		input mem_rdy, // Need Memory
		input [18:0] base_addr, // Read Data from Instructions
		output reg mem_re, // Need Memory
		output reg [18:0] addr, // Need Memory and Frame Buffer
		input frame_rdy, // Need Frame Buffer
		output reg frame_we, // Need Frame Buffer
		output reg [31:0] frame_data // Need Frame Buffer
	);
		
	draw_score dscore0(
		.clk(clk), 
		.rst_n(rst_n), 
		.start(draw_score_start), 
		score_data, // Need Registers or Memory
		score_valid_data, // ??
		frame_rdy, // Need Frame Buffer
		.done(draw_score_done), 
		score_re, // Need Registers or Memory
		score_addr,  // Need Registers or Memory
		frame_addr, // Need Frame Buffer
		frame_data, // Need Frame Buffer
		frame_we // Need Frame Buffer
	);

		input  clk ,rst_n, start, score_valid_data, frame_rdy;
		input  [31:0] score_data;
		output reg done, score_re, frame_we;
		output [3:0] score_addr;
		output [18:0] frame_addr;
		output [31:0] frame_data;
		
	sprite_counter scounter0(
		input clk, 
		input rst_n, 
		input next, 
		output done, 
		output reg[7:0] sprite_num
	);
		
	draw_sprite dsprite0(
		clk, 
		rst_n, 
		write_en, 
		frame_addr, 
		frame_data, 
		frame_write_valid, 
		rom_addr, 
		read_en, 
		rom_data_valid, 
		done, 
		coordinates, 
		img_sel, 
		start, 
		rom_data
	);
		
	input clk;
	input rst_n;

	// Move Logic inputs/outputs
	input [18:0] coordinates;
	reg [18:0] cord_flop;
	input [7:0] img_sel;
	reg [7:0] img_flop;
	input start;
	output reg done;

	// Frame buffer outputs
	input frame_write_valid;
	output [18:0] frame_addr;
	output [23:0] frame_data;
	output reg write_en;

	// Sprite Image Memory (ROM) input/outputs
	input [31:0] rom_data;
	input rom_data_valid;
	reg [31:0] rom_data_flop;
	output [13:0] rom_addr;
	output reg read_en;
	
endmodule