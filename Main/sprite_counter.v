module sprite_counter(input clk, input rst_n, input next, output reg sprite_num);
   
   wire next_sprite_num; //change back to 8-bit line after testing
   
   assign next_sprite_num = next ? sprite_num + 1 : sprite_num; 
   
   always@(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        sprite_num <= 1'b1;
     end
    else begin
        sprite_num <= next_sprite_num;
     end
   end

endmodule
