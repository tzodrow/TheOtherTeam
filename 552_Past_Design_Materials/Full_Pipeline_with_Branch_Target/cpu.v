// GROUP MADE UP OF:
// CARTER PETERSON
// JARED PIERCE
// NICK LEVIN

module cpu(clk, rst_n, hlt, pc);
	input clk, rst_n;
	output hlt;
	output wire [15:0] pc;
	
	
	//////////////////////////////////////////////
	//////      Cache Controllers        /////////
	//////////////////////////////////////////////
	
	wire MEM_cntrl_branch, i_rdy, d_rdy, MEM_cntrl_mem_read, MEM_cntrl_mem_write, i_re, EX_branch_was_taken;
	wire [15:0] IF_pc, IF_instr, MEM_alu_result, d_write_data, MEM_mem_output;
	
	assign i_re = (EX_branch_was_taken == MEM_cntrl_branch) ? 1'b1 : 1'b0;    //only time we aren't reading next instruction right away is if we are branching or jumping
	    
  //declare entire memory module so whole cpu can access it, instead of separating into different modules
  MemoryModule memoryModule(clk, rst_n, IF_pc, i_re, MEM_alu_result, MEM_cntrl_mem_read, MEM_cntrl_mem_write, d_write_data,
                            IF_instr, i_rdy, MEM_mem_output, d_rdy);
  
  
	//////////////////////////////////////////////
	///////    Instruction Fetch Stage     ///////
	//////////////////////////////////////////////
	
	//IF Stage Wires
	wire stall, ID_hlt, EX_hlt, MEM_hlt, pc_hlt, cache_stall, IF_stall, flush, IF_branch_was_taken;
	wire [6:0] EX_instr;
	wire [15:0] IF_pc_plus_one, IF_instr_old, MEM_jump_addr,  EX_pc_plus_one;
	
	assign pc = EX_pc_plus_one;//_plus_one;// + 100;
	
	assign pc_hlt = EX_hlt;     //when hlt instruction gets to EX stage, we know for sure the PC will halt
	
	assign cache_stall = (~i_rdy || ~d_rdy);	//always should be fetching one of these, so if one isn't ready we need to stall
	assign IF_stall = (stall || cache_stall);	//stall Fetch stage if we have cache stall or execution stall
	
	//IF Stage Module 	
	//IF instr_fetch(clk, rst_n, pc_hlt, IF_stall, MEM_jump_addr, MEM_cntrl_branch, IF_pc, IF_pc_plus_one, IF_instr, i_rdy);
	
	IF instr_fetch(clk, rst_n, pc_hlt, IF_stall, MEM_jump_addr, MEM_cntrl_branch, IF_instr, i_rdy, EX_instr, EX_pc_plus_one, EX_branch_was_taken,
                 IF_pc, IF_pc_plus_one, IF_branch_was_taken, flush);
	
	//////////////////////////////////////////////
	///////   Instruction Decode Stage     ///////
	//////////////////////////////////////////////

  //ID Stage Wires
  wire ID_cntrl_mem_write, ID_cntrl_mem_read, ID_cntrl_alu_src, ID_cntrl_reg_write, ID_cntrl_mem_to_reg, WB_cntrl_reg_write, ID_cntrl_pc_src, ID_jump_from_reg, ID_cntrl_branch_instr, ID_cntrl_re0, ID_cntrl_re1, ID_branch_was_taken;
  wire [1:0] ID_cntrl_flag_update;
  wire [2:0] ID_alu_op,  ID_cntrl_branch_op;
  wire [3:0] ID_shamt, ID_reg_write_addr, WB_reg_write_addr, ID_p0_addr, ID_p1_addr;
  wire [7:0] ID_immediate;
  wire [11:0] ID_jump_offset;
  wire [15:0] WB_reg_write_data, ID_pc_plus_one, ID_instr, ID_p0_data, ID_p1_data;
  
  //Connections for pipelines
	IF_ID_Pipe IF_ID(clk, rst_n, flush, IF_pc_plus_one, IF_instr, IF_stall, IF_branch_was_taken,
                   ID_pc_plus_one, ID_instr, ID_branch_was_taken);
	
	//ID Stage Module
	ID instr_decode(clk, rst_n, hlt, ID_instr, WB_cntrl_reg_write, WB_reg_write_addr, WB_reg_write_data, ID_pc_plus_one, 
	                ID_p0_data, ID_p1_data, ID_immediate, ID_jump_offset, ID_alu_op,  ID_cntrl_branch_op, ID_reg_write_addr, ID_shamt,
	                ID_cntrl_mem_write, ID_cntrl_mem_read, ID_cntrl_alu_src, ID_cntrl_reg_write, ID_cntrl_mem_to_reg, ID_cntrl_flag_update, ID_jump_from_reg, ID_cntrl_pc_src, ID_cntrl_branch_instr, ID_p0_addr, ID_p1_addr, ID_hlt, ID_cntrl_re0, ID_cntrl_re1);
	
	
	
	//////////////////////////////////////////////
	////////////   Execution Stage     ///////////
	//////////////////////////////////////////////
	
	//EX Stage Wires
	wire EX_cntrl_mem_write, EX_cntrl_mem_read, EX_cntrl_reg_write, EX_cntrl_mem_to_reg, EX_cntrl_alu_src, EX_jump_from_reg, EX_cntrl_reg_write_out, EX_cntrl_branch_instr, EX_cntrl_pc_src, EX_cntrl_re0, EX_cntrl_re1;
	wire EX_cntrl_src0_fwd, EX_cntrl_src1_fwd, EX_cntrl_src0_memex_fwd, EX_cntrl_src1_memex_fwd; 
	wire [1:0] EX_cntrl_flag_update;
	wire [2:0] EX_cntrl_branch_op, EX_alu_flags, EX_alu_op;
	wire [3:0] EX_shamt, EX_reg_write_addr, EX_p0_addr, EX_p1_addr;
	wire [7:0]  EX_immediate;
	wire [11:0] EX_jump_offset;
	wire [15:0] EX_jump_addr, EX_p0_data, EX_p1_data, EX_data_mem_data, EX_alu_result;
	
	//Connections for pipelines
	ID_EX_Pipe ID_EX(clk, rst_n, flush, ID_cntrl_mem_write, ID_cntrl_mem_read, ID_cntrl_alu_src, ID_reg_write_addr, ID_cntrl_flag_update, ID_jump_offset, ID_shamt, ID_cntrl_reg_write, ID_branch_was_taken,
                  ID_cntrl_mem_to_reg, ID_cntrl_branch_op, ID_alu_op, ID_p1_data, ID_p0_data, ID_immediate, ID_pc_plus_one, ID_cntrl_pc_src, ID_jump_from_reg, ID_cntrl_branch_instr, ID_p0_addr, ID_p1_addr, cache_stall, ID_instr[15:9], ID_hlt, ID_cntrl_re0, ID_cntrl_re1, stall,
                  EX_cntrl_mem_write, EX_cntrl_mem_read, EX_cntrl_alu_src, EX_reg_write_addr, EX_cntrl_flag_update, EX_jump_offset, EX_shamt, EX_cntrl_reg_write, EX_branch_was_taken,
                  EX_cntrl_mem_to_reg, EX_cntrl_branch_op, EX_alu_op, EX_p0_data, EX_p1_data, EX_immediate, EX_pc_plus_one, EX_cntrl_pc_src, EX_jump_from_reg, EX_cntrl_branch_instr, EX_p0_addr, EX_p1_addr, EX_instr, EX_hlt, EX_cntrl_re0, EX_cntrl_re1);

	
	//EX Stage Module, contains ALU
	EX execution(clk, rst_n, hlt, EX_p0_data, EX_p1_data, EX_alu_op, EX_immediate, EX_pc_plus_one, EX_jump_offset, EX_shamt, EX_cntrl_alu_src, EX_cntrl_flag_update, EX_cntrl_reg_write, EX_jump_from_reg, EX_cntrl_branch_instr, EX_cntrl_pc_src, EX_cntrl_src0_fwd, EX_cntrl_src1_fwd, EX_cntrl_src0_memex_fwd, EX_cntrl_src1_memex_fwd, MEM_alu_result, WB_reg_write_data, EX_instr[6:3], cache_stall, 
	             EX_jump_addr, EX_alu_flags, EX_alu_result, EX_cntrl_reg_write_out, EX_data_mem_data);
	
	
	//////////////////////////////////////////////
	////////////   Memory Stage     //////////////
	//////////////////////////////////////////////
	
	//Mem Stage Wires
	wire MEM_cntrl_reg_write, MEM_cntrl_pc_src, MEM_cntrl_mem_to_reg, MEM_cntrl_branch_instr, MEM_fwd_cntrl; //, MEM_cntrl_branch;
	wire [2:0] MEM_cntrl_branch_op, MEM_alu_flags;
	wire [3:0] MEM_reg_write_addr, MEM_p1_addr;
	wire [15:0] MEM_data_mem_data;
	
	//connections for pipelines
  EX_MEM_Pipe EX_MEM(clk, rst_n, EX_reg_write_addr, EX_cntrl_reg_write_out, EX_cntrl_mem_to_reg, EX_cntrl_mem_read, cache_stall,
                     EX_cntrl_mem_write, EX_data_mem_data, EX_alu_result, EX_cntrl_branch_op, EX_alu_flags, EX_jump_addr, EX_cntrl_pc_src, EX_cntrl_branch_instr, EX_p1_addr, EX_hlt,
                     MEM_reg_write_addr, MEM_cntrl_reg_write, MEM_cntrl_mem_to_reg, MEM_cntrl_mem_read,
                     MEM_cntrl_mem_write, MEM_data_mem_data, MEM_alu_result, MEM_cntrl_branch_op, MEM_alu_flags, MEM_jump_addr, MEM_cntrl_pc_src, MEM_cntrl_branch_instr, MEM_p1_addr, MEM_hlt);
	
	//Mem Stage Module
	MEM memory(clk, rst_n, hlt, MEM_data_mem_data, MEM_alu_flags, MEM_cntrl_branch_op, MEM_cntrl_pc_src, MEM_cntrl_branch_instr, MEM_fwd_cntrl, WB_reg_write_data,
	          MEM_cntrl_branch, d_write_data);
	
	
	//////////////////////////////////////////////
	///////////   Write Back Stage     ///////////
	//////////////////////////////////////////////
	
	//WB Stage Wires
	wire WB_cntrl_mem_to_reg;
	wire [15:0] WB_mem_output, WB_alu_output;
	
	//connections for future pipelines
	MEM_WB_Pipe MEM_WB(clk, rst_n, MEM_reg_write_addr, MEM_cntrl_reg_write, MEM_cntrl_mem_to_reg, MEM_mem_output, MEM_alu_result, MEM_hlt, cache_stall,
                  WB_reg_write_addr, WB_cntrl_reg_write, WB_cntrl_mem_to_reg, WB_mem_output, WB_alu_output, hlt);
	
	//WB Stage Module
  WB write_back(clk, rst_n, hlt, WB_mem_output, WB_alu_output, WB_cntrl_mem_to_reg, WB_reg_write_data);
  
  
  	/////////////////////////////////////
	////// Forwarding and Flush /////////
	/////////////////////////////////////
		
	//assign flush_real = MEM_cntrl_branch;   //we need to flush if we are taking a branch or jump
	
        //Forwarding control logic for EX, look at reg addresses from all stages of pipe and determine what needs to get forwarded where
	assign EX_cntrl_src0_fwd = (EX_cntrl_src0_memex_fwd || ((WB_reg_write_addr == EX_p0_addr) && WB_cntrl_reg_write)) && (EX_p0_addr != 1'h0) && (EX_cntrl_re0);
	assign EX_cntrl_src1_fwd = (EX_cntrl_src1_memex_fwd || ((WB_reg_write_addr == EX_p1_addr) && WB_cntrl_reg_write)) && (EX_p1_addr != 1'h0) && (EX_cntrl_re1);
	assign EX_cntrl_src0_memex_fwd = (MEM_reg_write_addr == EX_p0_addr) && MEM_cntrl_reg_write;
	assign EX_cntrl_src1_memex_fwd = (MEM_reg_write_addr == EX_p1_addr) && MEM_cntrl_reg_write;
	    
        //Forwarding control logic for MEM stage, will only happen if reg value that is being written back (SW) is being read immediately (LW)
	assign MEM_fwd_cntrl = (WB_reg_write_addr == MEM_p1_addr) && (MEM_p1_addr != 1'h0) && WB_cntrl_reg_write; 
	
        //only time we stall from an instruction sequence (excluding from caches/memory) is when we are 
        // loading a word from memory and performing an ALU op the next instruction (MSB of ID_instr = 0) 
	assign stall = (EX_instr[6:3] == 4'b1000) && (((EX_reg_write_addr == ID_p0_addr) && ID_cntrl_re0) || ((ID_instr[15] == 0) && (EX_reg_write_addr == ID_p1_addr) && ID_cntrl_re1)); 
	

endmodule
