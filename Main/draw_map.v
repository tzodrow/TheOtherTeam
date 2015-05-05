module draw_map(input clk, input rst, input start, output done,
               output frame_buf_we, output[16:0] frame_buf_addr, output[23:0] frame_buf_data);  
	 
	 reg[16:0] addr;
	 wire[16:0] next_addr;
	 
	 reg[1:0] state, next_state;
	 
	 localparam IDLE = 2'b00;
	 localparam READ_PIXEL = 2'b01;
	 localparam WRITE_PIXEL = 2'b10;
	 
	 assign next_addr = (state == WRITE_PIXEL) ? 
	                    (addr == 17'd76799) ? 0 : addr + 1 : addr;  //reset address after getting to end

	 assign frame_buf_addr = addr;
    assign frame_buf_we = (state == WRITE_PIXEL) ? 1'b1 : 1'b0;  
    
	 assign done = (state == IDLE) ? 1'b1 : 1'b0;
	 
	 always@(posedge clk, posedge rst) begin
		if(rst) begin
		   addr <= 17'd0;
		   state <= IDLE; 
		end
		else begin
		   addr <= next_addr;
		   state <= next_state;
		end
	 end
	  
	  always@(*) begin
	     next_state = IDLE;
	     case(state) 
	        IDLE: if(start) next_state = READ_PIXEL;
	        READ_PIXEL: next_state = WRITE_PIXEL; 
	        default : begin if(addr == 17'd76799) next_state = IDLE; //this is WRITE_PIXEL state
	                        else next_state = READ_PIXEL;
	                  end
	     endcase
	  end
	  
		map_memory MAP_MEMORY(
		  .clka(~clk), // 100 MHz clock, reading on negedge so data is available to write to fifo before posedge of clock
		  .addra(addr),	  // input [12 : 0] addra
		  .douta(frame_buf_data) // output [23 : 0] douta
		);

endmodule