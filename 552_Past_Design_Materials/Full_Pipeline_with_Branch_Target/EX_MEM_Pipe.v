//PIPELINE MODULE, a bunch of flops

module EX_MEM_Pipe(clk, rst_n, EX_reg_write_addr, EX_cntrl_reg_write_out, EX_cntrl_mem_to_reg, EX_cntrl_mem_read, stall,
                  EX_cntrl_mem_write, EX_data_mem_data, EX_alu_result, EX_cntrl_branch_op, EX_alu_flags, EX_jump_addr, EX_cntrl_pc_src, EX_cntrl_branch_instr, EX_p1_addr, EX_hlt,
                  MEM_reg_write_addr, MEM_cntrl_reg_write, MEM_cntrl_mem_to_reg, MEM_cntrl_mem_read,
                  MEM_cntrl_mem_write, MEM_data_mem_data, MEM_alu_result, MEM_cntrl_branch_op, MEM_alu_flags, MEM_jump_addr, MEM_cntrl_pc_src, MEM_cntrl_branch_instr, MEM_p1_addr, MEM_hlt);
                  
  input clk, rst_n, EX_cntrl_reg_write_out, EX_cntrl_mem_to_reg, EX_cntrl_mem_read, EX_cntrl_mem_write, EX_cntrl_pc_src, EX_cntrl_branch_instr, EX_hlt, stall;
  input [2:0] EX_cntrl_branch_op, EX_alu_flags;
  input [3:0] EX_reg_write_addr, EX_p1_addr;
  input [15:0] EX_data_mem_data, EX_alu_result, EX_jump_addr;
  
  output reg MEM_cntrl_reg_write, MEM_cntrl_mem_to_reg, MEM_cntrl_mem_read, MEM_cntrl_mem_write, MEM_hlt;
  output MEM_cntrl_pc_src, MEM_cntrl_branch_instr;
  output [2:0] MEM_alu_flags, MEM_cntrl_branch_op;
  output reg [3:0] MEM_reg_write_addr, MEM_p1_addr;
  output reg [15:0] MEM_data_mem_data, MEM_alu_result;
  output [15:0] MEM_jump_addr;
  
  assign MEM_alu_flags = EX_alu_flags;
  assign MEM_cntrl_branch_op = EX_cntrl_branch_op;
	assign MEM_jump_addr = EX_jump_addr;
	assign MEM_cntrl_pc_src = EX_cntrl_pc_src;
	assign MEM_cntrl_branch_instr = EX_cntrl_branch_instr;

  always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        //if resetting, flush all values
      MEM_reg_write_addr <= 0;
	    MEM_cntrl_reg_write <= 0;
	    MEM_cntrl_mem_to_reg <= 0;
	    MEM_cntrl_mem_read <= 0;
	    MEM_cntrl_mem_write <= 0;
	    MEM_data_mem_data <= 0;
	    MEM_alu_result <= 0;
	    MEM_p1_addr <= 0;
	    MEM_hlt <= 0;
	  end else if(stall) begin
            //if stalling, retain all previous values
	    MEM_reg_write_addr <= MEM_reg_write_addr;
	    MEM_cntrl_reg_write <= MEM_cntrl_reg_write;
	    MEM_cntrl_mem_to_reg <= MEM_cntrl_mem_to_reg;
	    MEM_cntrl_mem_read <= MEM_cntrl_mem_read;
	    MEM_cntrl_mem_write <= MEM_cntrl_mem_write;
	    MEM_data_mem_data <= MEM_data_mem_data;
	    MEM_alu_result <= MEM_alu_result;
	    MEM_p1_addr <= MEM_p1_addr;
	    MEM_hlt <= MEM_hlt;
	  end else begin
            //otherwise in normal operation just pass values down pipe
      MEM_reg_write_addr <= EX_reg_write_addr;
	    MEM_cntrl_reg_write <= EX_cntrl_reg_write_out;
	    MEM_cntrl_mem_to_reg <= EX_cntrl_mem_to_reg;
	    MEM_cntrl_mem_read <= EX_cntrl_mem_read;
	    MEM_cntrl_mem_write <= EX_cntrl_mem_write;
	    MEM_data_mem_data <= EX_data_mem_data;
	    MEM_alu_result <= EX_alu_result;
	    MEM_p1_addr <= EX_p1_addr;
	    MEM_hlt <= EX_hlt;
    end
  end
                  
endmodule
