`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:13:56 02/10/2014 
// Design Name: 
// Module Name:    vgamult 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module spu(clk_100mhz,  rst, pixel_r, pixel_g, pixel_b, hsync, vsync, blank, clk, clk_n, 
				D, dvi_rst, scl_tri, sda_tri, clk_100mhz_buf, data2output, data2output_2);
	 output [23:0] data2output, data2output_2;

    input clk_100mhz;
    input rst;
	 
	 output hsync;
    output vsync;
	 output blank;
	 output dvi_rst;
	 
	 output [7:0] pixel_r;
    output [7:0] pixel_g;
    output [7:0] pixel_b;
	 
	 output [11:0] D;
	 
	 output clk;
	 output clk_n;
	 output clk_100mhz_buf;
	 
	 wire counter_done;
	 
	 inout scl_tri, sda_tri;
	 
	 wire [9:0] pixel_x;
	 wire [9:0] pixel_y;
	 wire [23:0] pixel_gbrg;
	 
	 assign pixel_gbrg = {pixel_g[3:0], pixel_b, pixel_r, pixel_g[7:4]};
	 
	 wire clkin_ibufg_out;
	 wire locked_dcm;
	 
	 wire clk_25mhz;
	 wire clkn_25mhz;
	 wire comp_sync;
    
	 //wire shutdown;
	 
	 assign clk = clk_25mhz;
	 assign clk_n = ~clk_25mhz;
		
	 wire sda_tri;
	 wire scl_tri;
	 wire sda;
	 wire scl;
	 
	 //DVI Interface
	 assign dvi_rst = ~(rst|~locked_dcm);
	 assign D = (clk)? pixel_gbrg[23:12] : pixel_gbrg[11:0];
	 assign sda_tri = (sda)? 1'bz: 1'b0;
	 assign scl_tri = (scl)? 1'bz: 1'b0;
	 
	 
	 ms_counter ms_counter1(
		.clk(clk_100mhz_buf), // 100 MHz Clock
		.rst_n(~rst),
		.counter_done(counter_done)
		);
	 
	 wire draw_map_done, draw_sprite_done, move_logic_done;
	 wire draw_map_start, draw_sprite_start, move_logic_start;
	 wire draw_map_en, draw_sprite_en, move_logic_en;
	 
	 //assign draw_sprite_done = 1'b1;
	 
	 spu_controller spu_controller(
		.clk(clk_100mhz_buf),
		.rst_n(~rst),
		.counter_done(counter_done),
		.draw_map_done(draw_map_done),
		.move_logic_done(move_logic_done),
		.draw_map_start(draw_map_start),
		.move_logic_start(move_logic_start),
		.draw_map_en(draw_map_en),
		.move_logic_en(move_logic_en)
		);


		wire frame_we, map_frame_we, sprite_frame_we; 
		wire [16:0] frame_buf_addr, map_frame_buf_addr, sprite_frame_buf_addr;
		wire [23:0] frame_buf_data, map_frame_buf_data, sprite_frame_buf_data;
		
		draw_map draw_map0(.clk(clk_100mhz_buf), .rst(rst|~locked_dcm), .start(draw_map_start), .done(draw_map_done),
						.frame_buf_we(map_frame_we), .frame_buf_addr(map_frame_buf_addr), .frame_buf_data(map_frame_buf_data));


		assign frame_buff_data = (draw_map_en) ? map_frame_buf_data :
								(move_logic_en) ? sprite_frame_buf_data : 0;
		assign frame_buff_addr = (draw_map_en) ? map_frame_buf_addr:
								(move_logic_en) ? sprite_frame_buf_addr : 0;
		assign frame_we = (draw_map_en) ? map_frame_we :
						(move_logic_en) ? sprite_frame_we : 1'b0;
					
					
		wire [16:0] coordinates;
		wire [7:0] img_sel;
		wire [23:0] rom_data;
		//wire rom_data_valid;
		wire [13:0] rom_addr;
		wire sprite_read_en;
		
		wire sprite_data_re, sprite_data_we;
		wire[7:0] sprite_data_address; 
		wire[63:0] sprite_data_write_data, sprite_data_read_data;
		//assign coordinates = 0;
		//assign img_sel = 8'h00;
		
		assign sprite_data_read_data = 64'h8000000000000000;
		
		draw_sprite draw_sprite(.clk(clk_100mhz_buf), .rst_n(dvi_rst), .write_en(sprite_frame_we), .frame_addr(sprite_frame_buf_addr), .frame_data(sprite_frame_buf_data), 
						.frame_write_valid(1'b1), .rom_addr(rom_addr), .read_en(sprite_read_en), .rom_data_valid(1'b1), .done(draw_sprite_done), 
						.coordinates(coordinates), .img_sel(img_sel), .start(draw_sprite_start), .rom_data(rom_data));
						
		move_logic move_logic(.clk(clk_100mhz_buf), .rst_n(dvi_rst), .start(move_logic_start), .done(move_logic_done), .sprite_data_read_data(sprite_data_read_data), .draw_sprite_rdy(draw_sprite_done),   
						.draw_sprite_start(draw_sprite_start), .draw_sprite_image(img_sel), .draw_sprite_coordinates(coordinates),
						.sprite_data_re(sprite_data_re), .sprite_data_we(sprite_data_we), .sprite_data_address(sprite_data_address), .sprite_data_write_data(sprite_data_write_data));
						
						
						
		//Image ROM
		IMAGE_ROM sprite_image(
			.clka(clk_100mhz_buf),
			.addra(rom_addr[5:0]),
			.douta(rom_data)
		);
						
						
		wire fifo_full, fifo_empty, fifo_wr_en, fifo_rd_en;
		wire [23:0] fifo_in, fifo_out;
		wire [16:0] frame_read_addr; 				
		
		assign data2output = fifo_out;
		
		//assign fifo_in = 24'hFF0000;
		
		ROM FRAME_BUFFER (
		  .clka(clk_100mhz_buf), // input clka
		  .wea(frame_we), // input [0 : 0] wea
		  .addra(frame_buf_addr), // input [16 : 0] addra
		  .dina(frame_buf_data), // input [23 : 0] dina
		  .clkb(clk_100mhz_buf), // input clkb
		  .addrb(frame_read_addr), // input [16 : 0] addrb
		  .doutb(fifo_in) // output [23 : 0] doutb
		);
	 
	 
	 
	 dvi_ifc dvi1(.Clk(clk_25mhz),                     // Clock input
						.Reset_n(dvi_rst),       // Reset input
						.SDA(sda),                          // I2C data
						.SCL(scl),                          // I2C clock
						.Done(done),                        // I2C configuration done
						.IIC_xfer_done(iic_tx_done),        // IIC configuration done
						.init_IIC_xfer(1'b0)                // IIC configuration request
						);
	

	 

	// diff_clk clk_diff1(clkn_100mhz,  rst, clkn_25mhz, clknin_ibufg_out, clkn_100mhz_buf, lockedn_dcm);
	 vga_clk vga_clk_gen1(clk_100mhz, rst, clk_25mhz, clkin_ibufg_out, clk_100mhz_buf, locked_dcm);
	 
	  //instantiates ROM and connects to FIFO, runs at 100 MHz
    display_pane display_pane(	.clk(clk_100mhz_buf), 
											.rst(rst|~locked_dcm), 
											.fifo_full(fifo_full), 
											.fifo_wr_en(fifo_wr_en), 
											.addr(frame_read_addr),
											.data2output_2(data2output_2)
										);
	
	 //pulls from FIFO and outputs on proper pixel-lines (RGB), runs at 25 MHz
	 vga_logic vga_logic(clk_25mhz, rst|~locked_dcm, blank, comp_sync, hsync, vsync, pixel_x, pixel_y, fifo_out, fifo_rd_en, fifo_empty, pixel_r, pixel_g, pixel_b);
	 
	 //writes at 100 MHz, reads at 25 MHz
	 fifo fifo(		.rst(rst|~locked_dcm), // input rst
						.wr_clk(clk_100mhz_buf), // input wr_clk
						.rd_clk(clk_25mhz), // input rd_clk
						.din(fifo_in), // input [23 : 0] din
						.wr_en(fifo_wr_en), // input wr_en
						.rd_en(fifo_rd_en), // input rd_en
						.dout(fifo_out), // output [23 : 0] dout
						.full(fifo_full), // output full
						.empty(fifo_empty) // output empty
					);

	

	
	 
endmodule
