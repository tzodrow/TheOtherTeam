//MEMORY STAGE MODULE

module MEM(clk, rst_n, hlt, MEM_data_mem_data, MEM_alu_flags, MEM_cntrl_branch_op, cntrl_pc_src, cntrl_branch_instr, fwd_cntrl, WB_reg_write_data,      //INPUTS
	           cntrl_branch, write_data);       //OUTPUTS
  
  input clk, rst_n, hlt, cntrl_pc_src, cntrl_branch_instr, fwd_cntrl;
  input [2:0] MEM_alu_flags, MEM_cntrl_branch_op;
  input [15:0] MEM_data_mem_data, WB_reg_write_data;
  output cntrl_branch;
  output [15:0] write_data;
  
    //branch opcodes
  localparam NEQ = 3'b000;
  localparam EQ = 3'b001;
  localparam GT = 3'b010;
  localparam LT = 3'b011;
  localparam GTE = 3'b100;
  localparam LTE = 3'b101;
  localparam OVFL = 3'b110;
  localparam UNCOND = 3'b111;
  
  wire ZFlag, VFlag, NFlag;
  reg cntrl_branch_intermediate;
  
    //read in flags
  assign ZFlag = MEM_alu_flags[2];
  assign VFlag = MEM_alu_flags[1];
  assign NFlag = MEM_alu_flags[0];
    
    //if we are WB-MEM forwarding, make sure we get the writeback stage data 
  assign write_data = fwd_cntrl ? WB_reg_write_data : MEM_data_mem_data; 
  
     //look at branch op and check flags to decide whether we will branch or not
  assign cntrl_branch = (~cntrl_branch_instr) ? cntrl_pc_src :
                        (MEM_cntrl_branch_op == NEQ) ? !ZFlag :
                        (MEM_cntrl_branch_op == EQ) ? ZFlag :
                        (MEM_cntrl_branch_op == GT) ? ({ZFlag, NFlag} == 2'b00) :
                        (MEM_cntrl_branch_op == LT) ? NFlag :
                        (MEM_cntrl_branch_op == GTE) ? !NFlag :
                        (MEM_cntrl_branch_op == LTE) ? (NFlag | ZFlag) :
                        (MEM_cntrl_branch_op == OVFL) ? VFlag :
                        (MEM_cntrl_branch_op == UNCOND) ? 0 :
                        cntrl_pc_src;


endmodule
