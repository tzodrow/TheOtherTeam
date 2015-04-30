//
//EXECUTION MODULE, contains ALU
//
module EX(clk, rst_n, hlt, p0_data, p1_data, alu_op, immediate, pc_plus_one, jump_offset, shamt, cntrl_alu_src, flag_update_control, cntrl_reg_write_in, jump_from_reg, cntrl_branch_instr, cntrl_pc_src, cntrl_src0_fwd, cntrl_src1_fwd, cntrl_src0_memex_fwd, cntrl_src1_memex_fwd, MEM_alu_result, WB_reg_write_data, instr, stall,
	        jump_addr, alu_flags, alu_result, cntrl_reg_write_out, data_mem_data);
	        
  input clk, rst_n, hlt, cntrl_alu_src, cntrl_reg_write_in, jump_from_reg, cntrl_branch_instr, cntrl_pc_src, cntrl_src0_fwd, cntrl_src1_fwd, cntrl_src0_memex_fwd, cntrl_src1_memex_fwd, stall;
  input [1:0] flag_update_control;
  input [2:0] alu_op;
  input [3:0] shamt, instr;
  input [7:0] immediate;
  input [11:0] jump_offset;
  input [15:0] p0_data, p1_data, pc_plus_one, WB_reg_write_data, MEM_alu_result;
	
	output cntrl_reg_write_out;
	output reg [2:0] alu_flags;             
	output [15:0] jump_addr, alu_result, data_mem_data;
	
	//reg [1:0] flag_update_control_prev;
	wire [2:0] intermediate_flags;
	wire zr_flag, ov_flag, n_flag;
	wire [15:0] src1, alu_output_select, fwd_src0, fwd_src1, memex_fwd_src0, memex_fwd_src1;
	
        //operations from ID stage on what flags to set for operation
	localparam update_flags_none = 2'b00;
	localparam update_flags_z = 2'b01;
	localparam update_flags_nvz = 2'b10;
	localparam update_flags_addz = 2'b11;
	
        //calculate jump address for next pc value based on if it's a JR (takes reg value) or not
	assign jump_addr = (jump_from_reg) ? fwd_src0 : (pc_plus_one + {{4{jump_offset[11]}}, jump_offset});
	
        //if we are forwarding, be sure to grab the correct operands
	assign memex_fwd_src0 = cntrl_src0_memex_fwd ? MEM_alu_result : WB_reg_write_data;
	assign fwd_src0 = cntrl_src0_fwd ? memex_fwd_src0 : p0_data; 
	
        //module that determines whether to use immediate, src1, or forwarded src
	SRC_Mux src_mux(src1, cntrl_alu_src, immediate, fwd_src1);
	
        //if forwarding, be sure to choose the correct operands
	assign memex_fwd_src1 = cntrl_src1_memex_fwd ? MEM_alu_result : WB_reg_write_data;
	assign fwd_src1 = cntrl_src1_fwd ? memex_fwd_src1 : p1_data;
	assign data_mem_data = fwd_src1;
	    
        //actual ALU that performs the operations
	ALU alu(fwd_src0, src1, alu_op, shamt, alu_output_select, ov_flag, zr_flag, n_flag);	
	
        //if JAL instruction, choose pc val as alu value to writeback, otherwise just ALU output
	assign alu_result = (instr == 4'b1101) ? pc_plus_one : alu_output_select; 
        
        //determines whether to actually writeback to register or not (mainly for addz)
  assign cntrl_reg_write_out = (flag_update_control != update_flags_addz) ? cntrl_reg_write_in :
                               (alu_flags[2]) ? 1'b1 : 1'b0;
  
        //assign intermediates to be pushed to alu on next posedge clk
  assign intermediate_flags = (rst_n) ? {zr_flag, ov_flag, n_flag} : 3'b000;
  
       //update flags on clk based on flag control from ID
 	always@(posedge clk or negedge rst_n) begin
 	  if(~rst_n) begin 
        //on reset, flush the flags so we don't inadvertantly execute instructions
      alu_flags = 0;
    end else begin
        //if not flushed and we aren't stalling, continue to set flags each cycle
      if(!stall) begin
   	    if (flag_update_control == update_flags_z) begin
  	     alu_flags = {intermediate_flags[2], alu_flags[1:0]};
  	    end else if (flag_update_control == update_flags_nvz) begin
  	     alu_flags = intermediate_flags;
  	    end else if (flag_update_control == update_flags_addz) begin
  	     alu_flags = intermediate_flags;
  	    end else begin
  	     alu_flags = alu_flags;
  	    end
	    end else begin
	      alu_flags = alu_flags;
	    end
	 end
	end
	             
endmodule
