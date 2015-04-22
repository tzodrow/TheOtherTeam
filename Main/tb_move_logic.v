module tb_move_logic();


reg[15:0] i;

reg clk, rst_n, start, draw_sprite_rdy;
reg[63:0] sprite_data_read_data;

wire done, draw_sprite_start, sprite_data_re, sprite_data_we;
wire[7:0] draw_sprite_image, sprite_data_address;
wire[16:0] draw_sprite_coordinates;
wire[63:0] sprite_data_write_data; 

move_logic move_logic(clk, rst_n, start, done, sprite_data_read_data, draw_sprite_rdy,   
   draw_sprite_start, draw_sprite_image, draw_sprite_coordinates,
   sprite_data_re, sprite_data_we, sprite_data_address, sprite_data_write_data);

initial begin
	rst_n = 0;
	clk_pulse;
	rst_n = 1;
	clk_pulse;
	start = 1; 
	clk_pulse;
	start = 0; 
	sprite_data_read_data = 64'hF00A0B0302EE0000;
	draw_sprite_rdy = 1;
	clk_pulse10;
	clk_pulse10;
	clk_pulse10;
	clk_pulse10;
	clk_pulse10;
	clk_pulse500;
	sprite_data_read_data = 64'h300A0B0302EE0000;
	draw_sprite_rdy = 0;
	$stop;
	clk_pulse500;
  	$stop;
end

always@(*) begin
	if(sprite_data_we) sprite_data_read_data = sprite_data_write_data; 
	else sprite_data_read_data = sprite_data_read_data; 
end

always@(done) begin
	if(done) $stop;
end

task clk_pulse;
begin
clk = 0;
#5;
clk = 1;
#5; 
clk = 0; 
#5;
end
endtask

task clk_pulse10;
begin
for(i =0; i < 10; i = i + 1) begin
	#5;
	clk = 0;
	#5;
	clk = 1; 
end
end
endtask

task clk_pulse500;
begin
for(i =0; i < 500; i = i + 1) begin
	#5;
	clk = 0;
	#5;
	clk = 1; 
end
end
endtask



endmodule