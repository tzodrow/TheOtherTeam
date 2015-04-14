module move_logic(input clk, input rst_n, input start, 
   input sprite_data_active, input sprite_data_moving, input[18:0] sprite_data_coord, input[7:0] sprite_data_image, input[7:0] sprite_data_speed,
   input[1:0] sprite_data_direction, input draw_sprite_rdy,   
   output reg draw_sprite_start, 
   output reg sprite_data_re, output reg sprite_data_we, output reg[23:0] sprite_data_address, output reg[18:0] sprite_data_coord_write);

   localparam IDLE = 3'b000;
   localparam GET_SPRITE_NUM = 3'b001;
   localparam GET_SPRITE_FLAGS = 3'b010;
   localparam GET_COORD_DATA = 3'b011;
   localparam UPDATE_COORD = 3'b100;
   localparam STORE_COORD = 3'b101;
   localparam SEND_DRAW_SPRITE = 3'b110;
   
   wire sprite_counter_done;
   wire sprite_num;
   reg  sprite_counter_next; 
   reg[2:0] state, next_state;
   
   sprite_counter(clk, rst_n, sprite_counter_next, sprite_counter_done, sprite_num);
   
   always@(posedge clk, negedge rst_n) begin
      if(!rst_n) begin
         state <= IDLE;       
      end
      else begin
         state <= next_state;
      end
   end
   
   always@(*) begin
      next_state = IDLE; 
      sprite_counter_next = 1'b0;
      draw_sprite_start = 1'b0;
      sprite_data_re = 1'b0;
      sprite_data_we = 1'b0;
      sprite_data_address = 24'd0;
      sprite_data_coord_write = 19'd0;
      case(state)
         IDLE: begin
                 if(start) next_state = GET_SPRITE_NUM;
                 else next_state = IDLE;
              end 
         GET_SPRITE_NUM: begin
                 next_state = GET_SPRITE_FLAGS;
              end 
         GET_SPRITE_FLAGS: begin
                 if(sprite_data_active) next_state = GET_COORD_DATA;
                 else if(sprite_counter_done) next_state = IDLE;
                 else next_state = GET_SPRITE_NUM;
              end 
         GET_COORD_DATA: begin
                 if(sprite_data_moving) next_state = UPDATE_COORD;
                 else next_state = SEND_DRAW_SPRITE;
              end 
         UPDATE_COORD: begin
                 next_state = STORE_COORD;
              end 
         STORE_COORD: begin
                 next_state = SEND_DRAW_SPRITE;
              end 
         SEND_DRAW_SPRITE: begin
                 if(!draw_sprite_rdy) next_state = SEND_DRAW_SPRITE; 
                 else begin
                     
                    if(sprite_counter_done) next_state = IDLE;
                    else next_state = GET_SPRITE_NUM;
                end
              end 
         default: begin
              next_state = IDLE;
              end 
      
      endcase
       
   end




endmodule