module sprite_counter(input clk, input rst_n, input next, output done, output reg[7:0] sprite_num);
   wire[7:0] next_sprite_num;
   
   assign next_sprite_num = next ? sprite_num + 1 : sprite_num; 
   assign done = (sprite_num == 255) ? 1'b1 : 1'b0;
   
   always@(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        sprite_num <= 0;
     end
    else begin
        sprite_num <= next_sprite_num;
     end
   end

endmodule
