//PIPELINE MODULE, a bunch of flops

module IF_ID_Pipe(clk, rst_n, flush, IF_pc_plus_one, IF_instr, stall, IF_branch_was_taken,  //INPUTS
                  ID_pc_plus_one, ID_instr, ID_branch_was_taken);    //OUTPUTS
                            
  input clk, rst_n, flush, stall, IF_branch_was_taken;   //control signals for pipe
  input [15:0] IF_pc_plus_one, IF_instr;
  
  output reg ID_branch_was_taken;
  output reg [15:0] ID_pc_plus_one, ID_instr;
  
  always @(posedge clk or negedge rst_n) begin
        //on reset, flush all values and set flush indicator to 1
    if(~rst_n) begin
      ID_branch_was_taken <= 0;
      ID_pc_plus_one <= 0;
      ID_instr <= 16'hB000;
        //same as reset, but don't want to infer gated reset signal on flop
    end else if(flush) begin
      ID_branch_was_taken <= 0;
      ID_pc_plus_one <= 0;
      ID_instr <= 16'hB000;
        //on stall, retain values
    end else if(stall) begin
      ID_branch_was_taken <= ID_branch_was_taken;
      ID_pc_plus_one <= ID_pc_plus_one;
      ID_instr <= ID_instr;
        //otherwise in normal operation just pass values down pipe, set flush indicator to 0
    end else begin
      ID_branch_was_taken <= IF_branch_was_taken;
      ID_pc_plus_one <= IF_pc_plus_one;
      ID_instr <= IF_instr;
    end   
  end

endmodule
