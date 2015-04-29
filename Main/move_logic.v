module move_logic(input clk, input rst_n, input start, output done, input[63:0] sprite_data_read_data, input draw_sprite_rdy,   
   output draw_sprite_start, output [7:0] draw_sprite_image, output [16:0] draw_sprite_coordinates,
   output sprite_data_we, output[7:0] sprite_data_address, output[63:0] sprite_data_write_data);

   localparam IDLE = 3'b000;
   localparam GET_SPRITE_NUM = 3'b001;
   localparam GET_SPRITE_DATA = 3'b010;
   localparam UPDATE_COORD = 3'b011;
   localparam STORE_COORD = 3'b100;
   localparam SEND_DRAW_SPRITE = 3'b101;
	localparam WAIT_FOR_DRAW_SPRITE = 3'b110; 
   
   localparam DIR_UP = 2'b00;
   localparam DIR_DOWN = 2'b01;
   localparam DIR_LEFT = 2'b10;
   localparam DIR_RIGHT = 2'b11; 
   
   wire sprite_counter_done;
   wire sprite_num; //change back to 8 bit value
   wire  sprite_counter_next, sprite_data_active, sprite_data_moving, updated_sprite_moving; 
   wire[1:0] sprite_data_direction;
   reg[2:0] state, next_state;
   wire[7:0] sprite_data_image, sprite_data_speed, sprite_data_distance, sprite_data_y, sprite_data_x; 
   wire[7:0] updated_sprite_y, updated_sprite_distance, true_distance; 
	wire[8:0] updated_sprite_x;
   reg[63:0] sprite_data_saved;
   wire[63:0] next_sprite_data_saved;
   
   assign done = (state == IDLE) ? 1'b1 : 1'b0;  //indicate to controller when we are done/ready to start
   
	assign sprite_counter_done = (sprite_num == 1'b1) ? 1'b1 : 1'b0; 
	
   sprite_counter sprite_counter(clk, rst_n, sprite_counter_next, sprite_num);
   assign sprite_counter_next = (next_state == GET_SPRITE_NUM) ? 1'b1 : 1'b0; //changed to increment sprite_counter after saving off the previous data,
									// the memory should then be able to read that data right away
   
   assign sprite_data_we = (state == STORE_COORD) ? 1'b1 : 1'b0;
   assign sprite_data_address = sprite_num; 
   assign sprite_data_write_data = {sprite_data_saved[63], updated_sprite_moving, sprite_data_saved[61:56], 
   									updated_sprite_x[8:1], updated_sprite_y[7:0], updated_sprite_distance[7:0], sprite_data_saved[31:0]}; 
   assign next_sprite_data_saved = (state == GET_SPRITE_DATA) ? sprite_data_read_data : sprite_data_saved; 
   
   assign sprite_data_active = sprite_data_saved[63];
   assign sprite_data_moving = sprite_data_saved[62];
   assign sprite_data_direction = sprite_data_saved[61:60];
   assign sprite_data_x = sprite_data_saved[55:48];
   assign sprite_data_y = sprite_data_saved[47:40];
   assign sprite_data_distance = sprite_data_saved[39:32];
   assign sprite_data_speed = sprite_data_saved[31:24];
   assign sprite_data_image = sprite_data_saved[23:16];
    
   assign true_distance = (sprite_data_speed > sprite_data_distance) ? sprite_data_distance : sprite_data_speed; 
   assign updated_sprite_distance = sprite_data_distance - true_distance; 
   assign updated_sprite_moving = (updated_sprite_distance == 8'd0) ? 1'b0 : 1'b1; 
   
   assign updated_sprite_x = (sprite_data_moving == 1'b1) ?  
   							  (sprite_data_direction == DIR_LEFT) ? {sprite_data_x, 1'b0} - true_distance :  //might need to change because of x-coord only being 8 bits, not 9
   							  (sprite_data_direction == DIR_RIGHT) ? {sprite_data_x, 1'b0} + true_distance : {sprite_data_x, 1'b0} : {sprite_data_x, 1'b0}; 
   assign updated_sprite_y = (sprite_data_moving == 1'b1) ? 
   							  (sprite_data_direction == DIR_UP) ? sprite_data_y - true_distance : 
   							  (sprite_data_direction == DIR_DOWN) ? sprite_data_y + true_distance : sprite_data_y : sprite_data_y;

   
   assign draw_sprite_start = ((state == SEND_DRAW_SPRITE) && (draw_sprite_rdy == 1'b1)) ? 1'b1 : 1'b0;
   assign draw_sprite_image = sprite_data_image;
   assign draw_sprite_coordinates = updated_sprite_y * 320 + updated_sprite_x; //{updated_sprite_x[7:0], 1'b0, updated_sprite_y[7:0]}; //need to double the xcoordinate before sending to draw sprite
		//updated_sprite_y * 320 + {updated_sprite_x[7:0], 1'b0}; 

   //register updates --- sequential 
   always@(posedge clk, negedge rst_n) begin
      if(!rst_n) begin
         state <= IDLE;
         sprite_data_saved <= 64'd0;      
      end
      else begin
         state <= next_state;
         sprite_data_saved <= next_sprite_data_saved; 
      end
   end
   
   
   //next_state logic --- combinational
   always@(*) begin
      next_state = IDLE;
      case(state)
         IDLE: begin
                 if(start) begin
                    next_state = GET_SPRITE_NUM;
                    end
                 else begin
                    next_state = IDLE;
                    end
              end 
         GET_SPRITE_NUM: begin
                 next_state = GET_SPRITE_DATA;
              end 
         GET_SPRITE_DATA: begin
         	 next_state = UPDATE_COORD; 
              end 
         UPDATE_COORD: begin
                 if(sprite_data_active & sprite_data_moving) next_state = STORE_COORD;
                 else if(sprite_data_active) next_state = SEND_DRAW_SPRITE;
                 else if(sprite_counter_done) next_state = IDLE;
                 else next_state = GET_SPRITE_NUM;
              end 
         STORE_COORD: begin
                 next_state = SEND_DRAW_SPRITE;
              end 
         SEND_DRAW_SPRITE: begin
                 if((draw_sprite_rdy == 1'b0)) next_state = SEND_DRAW_SPRITE; 
                 else begin
						  next_state = WAIT_FOR_DRAW_SPRITE;
                end
              end 
         default: begin //WAIT_FOR_DRAW_SPRITE
						if((draw_sprite_rdy == 1'b0)) next_state = WAIT_FOR_DRAW_SPRITE; 
						else begin
							if(sprite_counter_done) next_state = IDLE;
							else next_state = GET_SPRITE_NUM;
						end
              end 
      
      endcase
       
   end

endmodule