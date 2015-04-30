//INSTRUCTION FETCH MODULE

module IF(clk, rst_n, hlt, stall, jump_addr, cntrl_branch, instr, i_rdy, EX_instr, EX_pc_plus_one, EX_branch_was_taken,
          pc, pc_plus_one, IF_branch_was_taken, flush);
          
  input clk, rst_n, hlt, cntrl_branch, stall, i_rdy, EX_branch_was_taken;
  input [6:0] EX_instr;
  input [15:0] jump_addr, instr, EX_pc_plus_one;

  output IF_branch_was_taken, flush;
  output [15:0] pc, pc_plus_one;
  
  wire cntrl_BTB_branch, BTB_taken, EX_is_branch;
  wire [3:0] instr_op;
  wire [11:0] jump_offset;
  wire [15:0] pc_input, pc_output;
  
  localparam Bi = 4'b1100;   //opcodes for instructions where we can branch right away in IF stage
  localparam JALi = 4'b1101;
  
  assign EX_is_branch = ((EX_instr[6:3] == Bi) && (EX_instr[2:0] != 3'b111)) ? 1'b1 : 1'b0;
  
  assign flush = (EX_branch_was_taken != cntrl_branch) ? 1'b1 : 1'b0;
    
  assign pc_plus_one = pc_output + 1;   //should not infer a very big adder
  
  assign IF_branch_was_taken = cntrl_BTB_branch;
  
  assign pc_input = (cntrl_branch && !EX_branch_was_taken) ? jump_addr :    //if we are branching, take that address
                    (!cntrl_branch && EX_branch_was_taken) ? EX_pc_plus_one :
                    (~i_rdy) ? pc_plus_one :            //check opcode and select next address based on offset of current pc  
                    (cntrl_BTB_branch || instr_op == JALi || ((instr_op == Bi) && instr[11:9] == 3'b111)) ? (pc_plus_one + {{4{jump_offset[11]}}, jump_offset}) :  pc_plus_one; 
  
  BTB btb(clk, rst_n, pc_plus_one[4:0], EX_is_branch, EX_pc_plus_one[4:0], cntrl_branch,
           BTB_taken);
  
  assign cntrl_BTB_branch =  (((instr_op == Bi) && instr[11:9] != 3'b111) && BTB_taken);
  
  assign pc = pc_output;

    //opcode is in 4 MSBs
  assign instr_op = instr[15:12];
  
    //jump offset is either sign extended immediate for branch or jump immediate
  assign jump_offset = (instr_op == Bi) ? {{3{instr[8]}},instr[8:0]} : instr[11:0];
  
    //assigns new PC value on posedge clk based on control signals
  PC pc_module(clk, rst_n, hlt, pc_input, pc_output, stall);

endmodule
