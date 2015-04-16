module draw_sprite_tb();
	
	reg clk, rst_n;

	reg [18:0] coordinates;
	reg [7:0] img_sel;
	reg start;
	wire done;

	reg frame_write_valid;
	wire [18:0] frame_addr;
	wire [23:0] frame_data;
	wire write_en;

	reg [31:0] rom_data;
	reg rom_data_valid;
	wire [13:0] rom_addr;
	wire read_en;

	reg [6:0] counter;

	draw_sprite iDUT(clk, rst_n, write_en, frame_addr, frame_data, rom_addr, read_en, done, coordinates, img_sel, move, start, rom_data);

	initial begin
		clk = 0;
		rst_n = 1;
		rom_data_valid = 0;
		frame_write_valid = 0;
		counter = 0;
		#3;
		rst_n = 0;
		#10;
		rst_n = 1;
		#7;
		coordinates = 0;
		img_sel = 0;
		start=1;
		#10;
		start = 0;
		
	end

	always begin
		#5;
		clk = ~clk;
	end

	always @(rom_addr) begin
		if(counter == 63) counter = 0;
		else counter = counter + 1;
	end

endmodule