module BTB(clk, rst_n, IF_pc_plus_one, EX_is_branch, EX_pc_plus_one, EX_branch_taken,
           BTB_taken);
           
           input clk, rst_n, EX_is_branch, EX_branch_taken;
           input [4:0]  EX_pc_plus_one, IF_pc_plus_one;
           
           output BTB_taken;
           
           reg mem[31:0];	// {tag[13:0], branch_taken}
           reg [6:0] x;
  
           always @(posedge clk or negedge rst_n) begin
              if (!rst_n) begin
                for (x=0; x<32;  x = x + 1)
            	     mem[x] = 0;		// only valid & dirty bit are cleared, all others are x
              end else if(EX_is_branch) begin
                mem[EX_pc_plus_one[4:0]] = {EX_branch_taken};
              end else begin
                mem[EX_pc_plus_one[4:0]] = mem[EX_pc_plus_one[4:0]];
              end
            end
            	
            /////////////////////////////////////////////////////////////
            // If tag bits match and line is valid then we have a hit //
            ///////////////////////////////////////////////////////////
            assign BTB_taken = mem[IF_pc_plus_one[4:0]];
  
endmodule