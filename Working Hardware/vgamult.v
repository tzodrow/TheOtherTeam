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
module vga(clk_100mhz,  rst, pixel_r, pixel_g, pixel_b, hsync, vsync, blank, clk, clk_n, D, dvi_rst, scl_tri, sda_tri, clk_100mhz_buf, data2output);
	 output [23:0] data2output;

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
	 
	 dvi_ifc dvi1(.Clk(clk_25mhz),                     // Clock input
						.Reset_n(dvi_rst),       // Reset input
						.SDA(sda),                          // I2C data
						.SCL(scl),                          // I2C clock
						.Done(done),                        // I2C configuration done
						.IIC_xfer_done(iic_tx_done),        // IIC configuration done
						.init_IIC_xfer(1'b0)                // IIC configuration request
						);
	

	 wire fifo_full, fifo_empty, fifo_wr_en, fifo_rd_en;
	 wire [23:0] fifo_in, fifo_out; 

	// diff_clk clk_diff1(clkn_100mhz,  rst, clkn_25mhz, clknin_ibufg_out, clkn_100mhz_buf, lockedn_dcm);
	 vga_clk vga_clk_gen1(clk_100mhz, rst, clk_25mhz, clkin_ibufg_out, clk_100mhz_buf, locked_dcm);
	 
	  //instantiates ROM and connects to FIFO, runs at 100 MHz
    display_pane display_pane(clk_100mhz_buf, rst|~locked_dcm, fifo_full, fifo_wr_en, fifo_in);
	
	 //pulls from FIFO and outputs on proper pixel-lines (RGB), runs at 25 MHz
	 vga_logic vga_logic(clk_25mhz, rst|~locked_dcm, blank, comp_sync, hsync, vsync, pixel_x, pixel_y, fifo_out, fifo_rd_en, fifo_empty, pixel_r, pixel_g, pixel_b);
	 
	 //writes at 100 MHz, reads at 25 MHz
	 FIFO fifo(
	  .rst(rst|~locked_dcm), // input rst
	  .wr_clk(clk_100mhz_buf), // input wr_clk
	  .rd_clk(clk_25mhz), // input rd_clk
	  .din(fifo_in), // input [23 : 0] din
	  .wr_en(fifo_wr_en), // input wr_en
	  .rd_en(fifo_rd_en), // input rd_en
	  .dout(fifo_out), // output [23 : 0] dout
	  .full(fifo_full), // output full
	  .empty(fifo_empty) // output empty
	);
	
	assign data2output = fifo_out;
	 
endmodule
