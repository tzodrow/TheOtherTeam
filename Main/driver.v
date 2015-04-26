`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////////////
// Company: UW Madison 
// Engineers: Tim Zodrow, Manjot S Pal, Jack
// 
// Create Date: 2/2/2015  
// Design Name: mini-spart
// Module Name: driver 
// Project Name: miniproject1
// Target Devices: FPGA
// Description: The driver starts initializes and drives the sparts transactions and receives
// data from the databus. It sets the baud rate from the br_cfg and sends out signals to 
// capture the data from the spart and send data back.

//////////////////////////////////////////////////////////////////////////////////////////////
module driver(
    input clk,
    input rst,
    input [1:0] br_cfg,
    output reg iocs,
    output reg iorw,
    input rda,
    input tbr,
    output reg [1:0] ioaddr,
    inout [7:0] databus,
	 input [23:0] data2output,
	 input [23:0] data2output_2
    );

    //////////////////////////////
    // States for State Machine //
    //////////////////////////////
    localparam INIT_LOW_DB = 3'b000;
    localparam INIT_HIGH_DB = 3'b001;
	 localparam RECEIVE_WAIT = 3'b010;
    localparam SEND = 3'b011;
    localparam SPACE = 3'b100;
	 localparam ADDRESS = 3'b101;

    ////////////////////////////////////////
    // Registers used for control signals //
    ////////////////////////////////////////
    reg sel,wrt_rx_data;

    // State Registers
    reg [3:0] state, nxt_state;
    // Data Registers
    reg [7:0] data_out, rx_data;
	 
	 reg [23:0] send_data;
	 reg [11:0] shift_counter;
	 wire [23:0] hex;
	 wire [7:0] ascii;
	 
	 reg ld_send_data, ld_send_data_2, ld_send_data_3;
	 reg rst_shift, dec_shift, rst_shift_2;

    // Tri-state buffer used to receive and send data via the databuse
    // Sel high = output, Sel low = input
	assign databus = sel ? data_out : 8'bz;
	assign hex = send_data >> (shift_counter << 2); 
	
	hex2ascii hex2ascii0(.hex(hex[3:0]), .ascii(ascii));
	
    // RX Received Data Flop
	always  @ (posedge clk, posedge rst) begin
		if(rst)
			rx_data <= 0;
		else if (wrt_rx_data)
			rx_data <= databus;
	end
	
    // State Flop
	always @ (posedge clk, posedge rst) begin
		if(rst)
			state <= 0;
		else
			state <= nxt_state;
	end
	
	always @ (posedge clk, posedge rst) begin
		if(rst)
			send_data <= 0;
		else if(ld_send_data)
			send_data <= data2output;
		else if(ld_send_data_2)
			send_data <= data2output_2;
	end
	
	always @ (posedge clk, posedge rst) begin
		if(rst)
			shift_counter <= 0; 
		else if(rst_shift)
			shift_counter <= 12'h005; // Value == 5
		else if(rst_shift_2)
			shift_counter <= 12'h005; // Value == 5
		else if(dec_shift)
			shift_counter <= shift_counter - 1;
	end

	///////////////////
    // State Machine //
    ///////////////////
    always@(*) begin
        // Initializations
		ioaddr = 2'b00;
		sel = 0;
		iocs = 1;
		iorw = 1;
		nxt_state = INIT_LOW_DB;
		data_out = 8'h00;
		wrt_rx_data = 0;
		rst_shift = 0;
		rst_shift_2 = 0;
		dec_shift = 0;
		ld_send_data = 0;
		ld_send_data_2 = 0;
		
		case(state)
            // Write the lower byte to Baud Gen
			INIT_LOW_DB: begin 
					ioaddr = 2'b10;
					sel = 1;
					nxt_state = INIT_HIGH_DB;
					case(br_cfg)	
						2'b00: 
								data_out = 8'hc0;		//baud rate to 4800
						2'b01:
								data_out = 8'h80;		//baud rate to 9600	
						2'b10: 
								data_out = 8'h00;		//baud rate to 19200	
						2'b11:
								data_out = 8'h00;		//baud rate to 38400
					endcase	
			end
			// Write the higher byte to Baud Gen
			INIT_HIGH_DB: begin
					ioaddr = 2'b11;
					sel = 1;
					nxt_state = RECEIVE_WAIT;
					case(br_cfg)	
						2'b00: 
								data_out = 8'h12;		//baud rate to 4800
						2'b01:
								data_out = 8'h25;		//baud rate to 9600	
						2'b10: 
								data_out = 8'h4b;		//baud rate to 19200	
						2'b11:
								data_out = 8'h96;		//baud rate to 38400
					endcase	
			end
			// Wait for receive data to be read
			RECEIVE_WAIT: begin
					if(~rda) begin
						nxt_state = RECEIVE_WAIT;
						iocs = 0;
					end
					else begin
						if(databus==8'h31) begin
							nxt_state = SEND;
							ld_send_data = 1;
							rst_shift = 1;
						end
						else if(databus==8'h32) begin
							nxt_state = SEND;
							ld_send_data_2 = 1;
							rst_shift_2 = 1;
						end
						else nxt_state = RECEIVE_WAIT;
						ioaddr = 2'b00;
					end
			end
			// Send receive data to TX when TX is ready for data
			SEND: begin
				if(tbr) begin					
					ioaddr = 2'b00;
					iorw = 0;
					data_out = ascii;
					sel = 1;
					if(shift_counter == 0)
						nxt_state = SPACE;
					else begin
						dec_shift = 1;
						nxt_state = SEND;
					end
				end
				else begin
					nxt_state = SEND;
				end
			end
			SPACE: begin
				if(tbr) begin
					ioaddr = 2'b00;
					iorw = 0;
					sel = 1;
					data_out = 8'h20; // SPACE Character
					nxt_state = RECEIVE_WAIT;
				end
				else begin
					nxt_state = SPACE;
				end
			end
		endcase
	end		
endmodule
