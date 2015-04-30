module sprite_counter(input clk, input rst_n, input next, output reg[2:0] sprite_num);
   
   wire[2:0] next_sprite_num; //change back to 8-bit line after testing
   
   assign next_sprite_num = next ? sprite_num + 1 : sprite_num; 
   
   always@(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        sprite_num <= 3'b111;
     end
    else begin
        sprite_num <= next_sprite_num;
     end
   end

endmodule
