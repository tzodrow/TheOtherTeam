//PIPELINE MODULE, a bunch of flops

module ID_EX_Pipe(clk, rst_n, flush, ID_cntrl_mem_write, ID_cntrl_mem_read, ID_cntrl_alu_src, ID_reg_write_addr, ID_cntrl_flag_update, ID_jump_offset, ID_shamt, ID_cntrl_reg_write, ID_branch_was_taken,
                  ID_cntrl_mem_to_reg, ID_cntrl_branch_op, ID_alu_op, ID_p1_data, ID_p0_data, ID_immediate, ID_pc_plus_one, ID_cntrl_pc_src, ID_jump_from_reg, ID_cntrl_branch_instr, ID_p0_addr, ID_p1_addr, stall, ID_instr, ID_hlt, ID_cntrl_re0, ID_cntrl_re1, insert_nop, 
                  EX_cntrl_mem_write, EX_cntrl_mem_read, EX_cntrl_alu_src, EX_reg_write_addr, EX_cntrl_flag_update, EX_jump_offset, EX_shamt, EX_cntrl_reg_write, EX_branch_was_taken,
                  EX_cntrl_mem_to_reg, EX_cntrl_branch_op, EX_alu_op, EX_p0_data, EX_p1_data, EX_immediate, EX_pc_plus_one, EX_cntrl_pc_src, EX_jump_from_reg, EX_cntrl_branch_instr, EX_p0_addr, EX_p1_addr, EX_instr, EX_hlt, EX_cntrl_re0, EX_cntrl_re1);

      input clk, rst_n, flush, ID_cntrl_mem_write, ID_cntrl_mem_read, ID_cntrl_alu_src, ID_cntrl_reg_write, ID_cntrl_mem_to_reg, ID_cntrl_pc_src, ID_jump_from_reg, ID_cntrl_branch_instr, stall, ID_hlt, ID_cntrl_re0, ID_cntrl_re1, insert_nop, ID_branch_was_taken;
      input [1:0] ID_cntrl_flag_update;
      input [2:0] ID_cntrl_branch_op, ID_alu_op;
      input [3:0] ID_reg_write_addr, ID_shamt, ID_p0_addr, ID_p1_addr;
      input [6:0] ID_instr;
      input [7:0] ID_immediate;
      input [11:0] ID_jump_offset;
      input [15:0] ID_p1_data, ID_p0_data, ID_pc_plus_one;
      
      output reg EX_cntrl_mem_write, EX_cntrl_mem_read, EX_cntrl_alu_src, EX_cntrl_reg_write, EX_cntrl_mem_to_reg, EX_cntrl_pc_src, EX_jump_from_reg, EX_cntrl_branch_instr, EX_hlt, EX_cntrl_re0, EX_cntrl_re1, EX_branch_was_taken;
      output reg [1:0] EX_cntrl_flag_update;
      output reg [2:0] EX_cntrl_branch_op, EX_alu_op;
      output reg [3:0] EX_reg_write_addr, EX_shamt, EX_p0_addr, EX_p1_addr;
      output reg [6:0] EX_instr;
      output reg [7:0] EX_immediate;
      output reg [11:0] EX_jump_offset;
      output reg [15:0] EX_p0_data, EX_p1_data, EX_pc_plus_one;
      
      always@(posedge clk or negedge rst_n) begin
      //on reset, flush all values
        if(~rst_n) begin
          EX_branch_was_taken <= 0;
          EX_cntrl_mem_write <= 0;
	        EX_cntrl_mem_read <= 0;
	        EX_cntrl_alu_src <= 0;
	        EX_reg_write_addr <= 0;
	        EX_cntrl_flag_update <= 0;
	        EX_jump_offset <= 0;
	        EX_shamt <= 0;
	        EX_cntrl_reg_write <= 0;
	        EX_cntrl_mem_to_reg <= 0;
	        EX_cntrl_branch_op <= 0;
	        EX_alu_op <= 0;
	        EX_p0_data <= 0;
	        EX_p1_data <= 0;
	        EX_cntrl_re0 <= 0;
	        EX_cntrl_re1 <= 0;
	        EX_immediate <= 0;
	        EX_pc_plus_one <= 0;
	        EX_cntrl_pc_src <= 0;
	        EX_jump_from_reg <= 0;
	        EX_cntrl_branch_instr <= 0;
	        EX_p0_addr <= 0; 
	        EX_p1_addr <= 0;
	        EX_instr <= 7'b1011000;
	        EX_hlt <= 0;
	      end else if (stall) begin
		    //on stall, retain all values
        		EX_branch_was_taken <= EX_branch_was_taken;
	        EX_cntrl_mem_write <= EX_cntrl_mem_write;
	        EX_cntrl_mem_read <= EX_cntrl_mem_read;
	        EX_cntrl_alu_src <= EX_cntrl_alu_src;
	        EX_reg_write_addr <= EX_reg_write_addr;
	        EX_cntrl_flag_update <= EX_cntrl_flag_update;
	        EX_jump_offset <= EX_jump_offset;
	        EX_shamt <= EX_shamt;
	        EX_cntrl_reg_write <= EX_cntrl_reg_write;
	        EX_cntrl_mem_to_reg <= EX_cntrl_mem_to_reg;
	        EX_cntrl_branch_op <= EX_cntrl_branch_op;
	        EX_alu_op <= EX_alu_op;
	        EX_p0_data <= EX_p0_data;
	        EX_p1_data <= EX_p1_data;
	        EX_cntrl_re0 <=  EX_cntrl_re0;
	        EX_cntrl_re1 <=  EX_cntrl_re1;
	        EX_immediate <= EX_immediate;
	        EX_pc_plus_one <= EX_pc_plus_one;
	        EX_cntrl_pc_src <= EX_cntrl_pc_src;
	        EX_jump_from_reg <= EX_jump_from_reg;
	        EX_cntrl_branch_instr <= EX_cntrl_branch_instr;
	        EX_p0_addr <= EX_p0_addr; 
	        EX_p1_addr <= EX_p1_addr;
	        EX_instr <= EX_instr; 
	        EX_hlt <= EX_hlt;
	      end else if (flush || insert_nop) begin
        //if flushing or a nop is necessary, flush all values
          EX_branch_was_taken <= 0;
          EX_cntrl_mem_write <= 0;
	        EX_cntrl_mem_read <= 0;
	        EX_cntrl_alu_src <= 0;
	        EX_reg_write_addr <= 0;
	        EX_cntrl_flag_update <= 0;
	        EX_jump_offset <= 0;
	        EX_shamt <= 0;
	        EX_cntrl_reg_write <= 0;
	        EX_cntrl_mem_to_reg <= 0;
	        EX_cntrl_branch_op <= 0;
	        EX_alu_op <= 0;
	        EX_p0_data <= 0;
	        EX_p1_data <= 0;
	        EX_cntrl_re0 <= 0;
	        EX_cntrl_re1 <= 0;
	        EX_immediate <= 0;
	        EX_pc_plus_one <= 0;
	        EX_cntrl_pc_src <= 0;
	        EX_jump_from_reg <= 0;
	        EX_cntrl_branch_instr <= 0;
	        EX_p0_addr <= 0; 
	        EX_p1_addr <= 0;
	        EX_instr <= 7'b1011000;
	        EX_hlt <= 0;
        end else if(~EX_hlt) begin
        //as long as halt isn't asserted, continue normal operation by passing values down pipe
          EX_branch_was_taken <= ID_branch_was_taken;
          EX_cntrl_mem_write <= ID_cntrl_mem_write;
	        EX_cntrl_mem_read <= ID_cntrl_mem_read;
	        EX_cntrl_alu_src <= ID_cntrl_alu_src;
	        EX_reg_write_addr <= ID_reg_write_addr;
	        EX_cntrl_flag_update <= ID_cntrl_flag_update;
	        EX_jump_offset <= ID_jump_offset;
	        EX_shamt <= ID_shamt;
	        EX_cntrl_reg_write <= ID_cntrl_reg_write;
	        EX_cntrl_mem_to_reg <= ID_cntrl_mem_to_reg;
	        EX_cntrl_branch_op <= ID_cntrl_branch_op;
	        EX_alu_op <= ID_alu_op;
	        EX_p0_data <= ID_p0_data;
	        EX_p1_data <= ID_p1_data;
	        EX_cntrl_re0 <=  ID_cntrl_re0;
	        EX_cntrl_re1 <=  ID_cntrl_re1;
	        EX_immediate <= ID_immediate;
	        EX_pc_plus_one <= ID_pc_plus_one;
	        EX_cntrl_pc_src <= ID_cntrl_pc_src;
	        EX_jump_from_reg <= ID_jump_from_reg;
	        EX_cntrl_branch_instr <= ID_cntrl_branch_instr;
	        EX_p0_addr <= ID_p0_addr; 
	        EX_p1_addr <= ID_p1_addr;
	        EX_instr <= ID_instr; 
	        EX_hlt <= ID_hlt;
	      end else begin
          //if halting, quit passing values down pipe
          EX_branch_was_taken <= EX_branch_was_taken;
	        EX_cntrl_mem_write <= EX_cntrl_mem_write;
	        EX_cntrl_mem_read <= EX_cntrl_mem_read;
	        EX_cntrl_alu_src <= EX_cntrl_alu_src;
	        EX_reg_write_addr <= EX_reg_write_addr;
	        EX_cntrl_flag_update <= EX_cntrl_flag_update;
	        EX_jump_offset <= EX_jump_offset;
	        EX_shamt <= EX_shamt;
	        EX_cntrl_reg_write <= EX_cntrl_reg_write;
	        EX_cntrl_mem_to_reg <= EX_cntrl_mem_to_reg;
	        EX_cntrl_branch_op <= EX_cntrl_branch_op;
	        EX_alu_op <= EX_alu_op;
	        EX_p0_data <= EX_p0_data;
	        EX_p1_data <= EX_p1_data;
	        EX_cntrl_re0 <=  EX_cntrl_re0;
	        EX_cntrl_re1 <=  EX_cntrl_re1;
	        EX_immediate <= EX_immediate;
	        EX_pc_plus_one <= EX_pc_plus_one;
	        EX_cntrl_pc_src <= EX_cntrl_pc_src;
	        EX_jump_from_reg <= EX_jump_from_reg;
	        EX_cntrl_branch_instr <= EX_cntrl_branch_instr;
	        EX_p0_addr <= EX_p0_addr; 
	        EX_p1_addr <= EX_p1_addr;
	        EX_instr <= EX_instr; 
	        EX_hlt <= EX_hlt;
	      end
      end
	
endmodule
