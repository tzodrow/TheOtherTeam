module cpu(input clk, input rst_n, output hlt, output[21:0] pc);

//system-wide declarations 
wire stall; 


//system-wide assigns 


//wires from WB to Decode
wire WB_mem_ALU_select, WB_use_dst_reg;
wire [31:0] reg_WB_data;



//////////////////
//Intruction Fetch
//////////////////

//IF Stage Wire Declarations
wire IF_instr_mem_re;
wire[21:0] IF_PC, IF_next_PC;
wire[31:0] IF_instr;
wire ID_is_branch; //used for determining next_PC value
wire[21:0] ID_branch_addr; //used for determining 

//IF Logic
assign pc = IF_PC;

pc PC(clk, rst_n, IF_next_PC, IF_PC);

assign IF_instr_mem_re = ~stall; 	
assign IF_next_PC = stall ? IF_PC : ID_is_branch ? ID_branch_addr : IF_PC + 1;

//IF Module Declaration
instr_fetch instr_fetch(clk, rst_n, IF_instr_mem_re, IF_PC, IF_instr);

//
//////////////////
//Instruction Decode
//////////////////
//

//ID Stage Wire Declarations
wire ID_hlt, ID_use_imm, ID_use_dst_reg;
wire ID_update_neg, ID_update_carry, ID_update_ov, ID_update_zero; //flag updates
wire[2:0] ID_alu_opcode, ID_branch_conditions;
wire[4:0] ID_dst_reg;
wire[16:0] ID_imm; 
wire[21:0] ID_PC, ID_PC_out;
wire[31:0] ID_instr, ID_s_data, ID_t_data; 
wire ID_mem_alu_select, ID_mem_we, ID_mem_re, ID_use_sprite_mem;

//sprite wires
wire ID_sprite_use_imm, ID_sprite_re, ID_sprite_we, ID_sprite_use_dst_reg;
wire[3:0] ID_sprite_action;
wire[7:0] ID_sprite_addr;
wire[13:0] ID_sprite_imm;

//SPART
wire IOR;

//From WB Stage to Reg File in decode module
wire WB_we;
wire [4:0] WB_dst_reg;
wire [31:0] WB_dst_reg_data_WB;


//////////////////
//PIPE: Instruction Fetch - Instruction Decode
//////////////////
IF_ID_pipeline_reg IF_ID_pipeline_Test(.clk(clk), .rst_n(rst_n), .hlt(hlt), .stall(stall), .flush(flush), .IF_instr(IF_instr), .ID_instr(ID_instr), .IF_PC(IF_PC), .ID_PC(ID_PC));


//ID Logic


//ID Module Declaration
instr_decode inst_decTest(.clk(clk), .rst_n(rst_n), .instr(ID_instr), .alu_opcode(ID_alu_opcode), .imm(ID_imm), .regS_data_ID(ID_s_data), .regT_data_ID(ID_t_data), .use_imm(ID_use_imm),
	  .use_dst_reg(ID_use_dst_reg), .is_branch_instr(ID_is_branch), .update_neg(ID_update_neg), .update_carry(ID_update_carry), .update_overflow(ID_update_ov), 
	  .update_zero(ID_update_zero), .sprite_addr(ID_sprite_addr), .sprite_action(ID_sprite_action), .sprite_use_imm(ID_sprite_use_imm), .sprite_imm(ID_sprite_imm),
	  .sprite_re(ID_sprite_re), .sprite_we(ID_sprite_we), .sprite_use_dst_reg(ID_sprite_use_dst_reg), .IOR(IOR), .dst_reg(ID_dst_reg), .hlt(ID_hlt),
	  .PC_in(ID_PC), .PC_out(ID_PC_out), .dst_reg_WB(WB_dst_reg), .dst_reg_data_WB(reg_WB_data), .we(WB_use_dst_reg), .branch_addr(ID_branch_addr), .branch_conditions(ID_branch_conditions),
	  .mem_alu_select(ID_mem_alu_select), .mem_we(ID_mem_we), .mem_re(ID_mem_re), .use_sprite_mem(ID_use_sprite_mem));


//////////////////
//Execute
//////////////////

//EX Stage Wire Declarations

wire EX_use_imm;
wire EX_update_ov, EX_update_neg, EX_update_carry, EX_update_zero;
wire EX_ov, EX_neg, EX_zero, EX_carry;
wire[2:0] EX_alu_opcode;
wire[16:0] EX_imm;
wire[31:0] EX_s_data, EX_t_data, EX_ALU_result;

//sprite wires
wire EX_sprite_use_imm, EX_sprite_re, EX_sprite_we, EX_sprite_use_dst_reg;
wire[3:0] EX_sprite_action;
wire[7:0] EX_sprite_addr;
wire[13:0] EX_sprite_imm;
wire[31:0] EX_sprite_data;


//////////////////
//PIPE: Instruction Decode - Execute
//////////////////


ID_EX_pipeline_reg ID_EX_pipeline_Test(clk, rst_n, stall, hlt, flush, ID_PC, ID_PC_out, ID_s_data, ID_t_data, ID_use_imm, 
	ID_use_dst_reg, ID_update_neg, ID_update_carry, ID_update_ov, ID_update_zero, ID_alu_opcode, ID_branch_conditions,
	ID_imm, ID_dst_reg, ID_sprite_addr, ID_sprite_action, ID_sprite_use_imm, ID_sprite_re, ID_sprite_we, 
	ID_sprite_use_dst_reg, ID_sprite_imm, ID_mem_alu_select, ID_mem_we, ID_mem_re, ID_use_sprite_mem, EX_PC, EX_PC_out, EX_s_data, EX_t_data,EX_use_imm, 
	EX_use_dst_reg, EX_update_neg, EX_update_carry, EX_update_ov, EX_update_zero, EX_alu_opcode, EX_branch_conditions,
	EX_imm, EX_dst_reg, EX_sprite_addr, EX_sprite_action, EX_sprite_use_imm, EX_sprite_re, EX_sprite_we, 
	EX_sprite_use_dst_reg, EX_sprite_imm, EX_mem_alu_select, EX_mem_we, EX_mem_re, EX_use_sprite_mem);
/*
ID_EX_pipeline_reg ID_EX_pipeline_Test(clk, rst_n, .stall(), .hlt(), .flush(), .ID_PC(), .ID_PC_out(), .ID_instr(), .ID_s_data(), .ID_t_data(), .ID_use_imm(), 
	.ID_use_dst_reg(), .ID_update_neg(), .ID_update_carry(), .ID_update_ov(), .ID_update_zero(), .ID_alu_opcode(), .ID_branch_conditions(),
	.ID_imm(), .ID_dst_reg(), .ID_sprite_addr(), .ID_sprite_action(), .ID_sprite_use_imm(), .ID_sprite_re(), .ID_sprite_we(), 
	.ID_sprite_use_dst_reg(), .ID_sprite_imm(), .EX_PC(), .EX_PC_out(), .EX_s_data(), .EX_t_data(),.EX_use_imm(), 
	.EX_use_dst_reg(), .EX_update_neg(), .EX_update_carry(), .EX_update_ov(), .EX_update_zero(), .EX_alu_opcode(), .EX_branch_conditions(),
	.EX_imm(), .EX_dst_reg(), .EX_sprite_addr(), .EX_sprite_action(), .EX_sprite_use_imm(), .EX_sprite_re(), .EX_sprite_we(), 
	.EX_sprite_use_dst_reg(), .EX_sprite_imm());

	//EX_PC, EX_PC_out, EX_use_dst_reg, EX_dst_reg - need to be pipelined later on after pipelining is done by Chris - skip the EX stage
*/
//EX Logic



//EX Module Declaration
EX EX(.clk(clk), .rst_n(rst_n), .alu_opcode(EX_alu_opcode), .update_ov(EX_update_ov), .update_neg(EX_update_neg), .update_zero(EX_update_zero), .update_carry(EX_update_carry),
           .t_data(EX_t_data), .s_data(EX_s_data), .imm(EX_imm), .use_imm(EX_use_imm), .sprite_action(EX_sprite_action), .sprite_imm(EX_sprite_imm), 
	   .sprite_use_imm(EX_sprite_use_imm), .sprite_addr(EX_sprite_addr),.sprite_re(EX_sprite_re), .sprite_we(EX_sprite_we), .sprite_use_dst_reg(EX_sprite_use_dst_reg), // < ^inputs 
	   .ALU_result(EX_ALU_result), .sprite_data(EX_sprite_data), .ov(EX_ov), .neg(EX_neg), .zero(EX_zero), .carry(EX_carry) //outputs
	);
//MEM Stage Wire Declarations

wire MEM_sprite_ALU_select, MEM_mem_ALU_select, MEM_flag_ov, MEM_flag_neg, MEM_flag_zero, MEM_re, MEM_we, MEM_use_dst_reg, MEM_use_sprite_mem;
wire [2:0] MEM_branch_cond;
wire [4:0] MEM_addr;
wire [21:0] MEM_PC, MEM_PC_out;
wire [31:0] MEM_data, MEM_sprite_data, MEM_instr;

//////////////////
//PIPE: Execute - Memory
//////////////////

EX_MEM_pipeline_reg ex_mem_pipe_Test(clk, rst_n, hlt, stall, flush, EX_ov, EX_neg, EX_zero, EX_use_dst_reg, EX_branch_conditions, EX_dst_reg, EX_PC, EX_PC_out, EX_instr, EX_ALU_result, EX_sprite_data, EX_s_data, EX_re, EX_we, EX_mem_ALU_select, EX_use_sprite_mem, //Inputs
							MEM_sprite_ALU_select, MEM_mem_ALU_select, MEM_flag_ov, MEM_flag_neg, MEM_flag_zero, MEM_re, MEM_we, MEM_addr, MEM_PC, MEM_PC_out, MEM_data, MEM_sprite_data, MEM_instr, MEM_branch_cond, MEM_use_dst_reg,
							MEM_use_sprite_mem, MEM_dst_reg);
/*
EX_MEM_pipeline_reg ex_mem_pipe_Test(.clk(), .rst_n(), .hlt(), .stall(), .flush(), .EX_ov(), .EX_neg(), .EX_zero(), .EX_use_dst_reg(), .EX_branch_conditions(), 
					.EX_dst_reg(), .EX_PC(), .EX_PC_out(), .EX_instr(), .EX_ALU_result(), .EX_sprite_data(), .EX_s_data(), .EX_re(), 
					.EX_we(), .EX_mem_ALU_select(), .EX_use_sprite_mem(), //Inputs
					.MEM_sprite_ALU_select(), .MEM_mem_ALU_select(), .MEM_flag_ov(), .MEM_flag_neg(), .MEM_flag_zero(), .MEM_re(),
					.MEM_we(), .MEM_addr(), .MEM_PC(), .MEM_PC_out(), .MEM_data(), .MEM_sprite_data(), .MEM_instr(), .MEM_branch_cond(), 
					.MEM_use_dst_reg(), .MEM_use_sprite_mem());  //Outputs
*/



//MEM Logic


//MEM Module Declaration


//////////////////
//Memory
//////////////////


wire [21:0] WB_PC, WB_PC_out;
wire [31:0] WB_mem_result, WB_sprite_ALU_result, WB_instr; 

MEM mem_Test(.clk(clk), .rst_n(rst_n), .mem_data(EX_s_data), .addr(EX_ALU_result), .re(MEM_re), .we(MEM_we), .sprite_data(MEM_sprite_data), 
	     .sprite_ALU_select(sprite_ALU_select), .mem_ALU_select(mem_ALU_select), .flag_ov(flag_ov), 
	     .flag_neg(MEM_flag_neg), .flag_zero(MEM_flag_zero), .branch_condition(MEM_branch_cond), //Inputs
             .cache_hit(cache_hit), .mem_ALU_WB_select(MEM_mem_ALU_select), .sprite_ALU_result(MEM_sprite_ALU_select),
	     .mem_result(MEM_mem_result), .branch_taken(MEM_branch_taken)); //Outputs
		   
//WB Stage Wire Declarations

//////////////////
//PIPE: Memory - Writeback
//////////////////


MEM_WB_pipeline_reg mem_wb_pipe_Test(clk, rst_n, hlt, stall, flush, MEM_mem_ALU_select, MEM_PC, MEM_PC_out, MEM_dst_reg,
				     MEM_ALU_result, MEM_sprite_ALU_result, MEM_instr, MEM_use_dst_reg, //Inputs
				     WB_mem_ALU_select, WB_PC, WB_PC_out, WB_mem_result, WB_sprite_ALU_result, WB_instr, WB_use_dst_reg, WB_dst_reg);  //Outputs



//WB Logic


//WB Module Declaration

//////////////////
//Writeback
//////////////////

WB wb_Test(.clk(clk), .rst_n(rst_n), .mem_result(mem_result), .sprite_ALU_result(sprite_ALU_result), .mem_ALU_select(mem_ALU_select), //Inputs
		  .reg_WB_data(reg_WB_data)); //Outputs

	//reg mem_ALU_select;
	//reg [31:0] mem_result, sprite_ALU_result;
	//wire [31:0] reg_WB_data;



endmodule
