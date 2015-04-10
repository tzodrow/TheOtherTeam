module cpu(input clk, input rst_n, output hlt, output[21:0] pc);

//system-wide declarations 
wire stall; 


//system-wide assigns 


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


//sprite wires
wire ID_sprite_use_imm, ID_sprite_re, ID_sprite_we, ID_sprite_use_dst_reg;
wire[3:0] ID_sprite_action;
wire[7:0] ID_sprite_addr;
wire[13:0] ID_sprite_imm;

//SPART
wire IOR;

//From WB Stage to Reg File in decode module
wire WB_we;
wire [4:0] WB_dst_reg_WB;
wire [31:0] WB_dst_reg_data_WB;


//////////////////
//PIPE: Instruction Fetch - Instruction Decode
//////////////////
IF_ID_pipeline_reg IF_ID_pipeline_Test(.clk(clk), .rst_n(rst_n), .hlt(hlt), .stall(stall), .flush(flush), .IF_instr(IF_instr), .ID_instr(ID_instr), .IF_PC(IF_PC), .ID_PC(ID_PC));


//ID Logic


//ID Module Declaration
instr_decode inst_decTest(clk,rst_n, ID_instr, ID_alu_opcode, ID_imm, ID_s_data, ID_t_data, ID_use_imm,
	  ID_use_dst_reg, ID_is_branch, ID_update_neg, ID_update_carry, ID_update_ov, ID_update_zero, ID_sprite_addr, 
	  ID_sprite_action, ID_sprite_use_imm, ID_sprite_imm, /*sprite_reg_data,*/ ID_sprite_re, ID_sprite_we, ID_sprite_use_dst_reg, IOR, ID_dst_reg, ID_hlt,
	  ID_PC, ID_PC_out, WB_dst_reg_WB, WB_dst_reg_data_WB, WB_we, ID_branch_addr, ID_branch_conditions);

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

ID_EX_pipeline_reg ID_EX_pipeline_Test(clk, rst_n, stall, hlt, flush, ID_PC, ID_PC_out, ID_instr, ID_s_data, ID_t_data, ID_use_imm, 
	ID_use_dst_reg, ID_update_neg, ID_update_carry, ID_update_ov, ID_update_zero, ID_alu_opcode, ID_branch_conditions,
	ID_imm, ID_dst_reg, ID_sprite_addr, ID_sprite_action, ID_sprite_use_imm, ID_sprite_re, ID_sprite_we, 
	ID_sprite_use_dst_reg, ID_sprite_imm, EX_PC, EX_PC_out, EX_s_data, EX_t_data, EX_use_imm, 
	EX_use_dst_reg, EX_update_neg, EX_update_carry, EX_update_ov, EX_update_zero, EX_alu_opcode, EX_branch_conditions,
	EX_imm, EX_dst_reg, EX_sprite_addr, EX_sprite_action, EX_sprite_use_imm, EX_sprite_re, EX_sprite_we, 
	EX_sprite_use_dst_reg, EX_sprite_imm);

	//EX_PC, EX_PC_out, EX_use_dst_reg, EX_dst_reg - need to be pipelined later on after pipelining is done by Chris - skip the EX stage

//EX Logic


//EX Module Declaration
EX EX(clk, EX_alu_opcode, EX_update_ov, EX_update_neg, EX_update_zero, EX_update_carry,
           EX_t_data, EX_s_data, EX_imm, EX_use_imm, EX_sprite_action, EX_sprite_imm, EX_sprite_use_imm, EX_sprite_addr,
	   EX_sprite_re, EX_sprite_we, EX_sprite_use_dst_reg, // < ^inputs 
	   EX_ALU_result, EX_sprite_data, EX_ov, EX_neg, EX_zero, EX_carry //outputs
	);

//////////////////
//Memory
//////////////////


MEM mem_Test(.clk(clk), .rst_n(rst_n), .mem_data(EX_s_data), .addr(EX_ALU_result), .cmd(cmd), .sprite_data(sprite_data), 
	     .sprite_ALU_select(sprite_ALU_select), .mem_ALU_select(mem_ALU_select), .flag_ov(flag_ov), 
	     .flag_neg(flag_neg), .flag_zero(flag_zero), .branch_condition(EX_branch_conditions), //Inputs
             .cache_hit(cache_hit), .mem_ALU_WB_select(mem_ALU_WB_select), .sprite_ALU_result(sprite_ALU_result),
	     .mem_result(mem_result), .branch_taken(branch_taken)); //Outputs
		   
	//reg cmd, sprite_ALU_select, mem_ALU_select, flag_ov, flag_neg, flag_zero;
	//reg [2:0] branch_condition;
	//reg [31:0] mem_data, sprite_data;
	//reg [21:0] addr;
	//wire cache_hit, mem_ALU_WB_select, branch_taken;
	//wire [31:0] sprite_ALU_result, mem_result;


//MEM Stage Wire Declarations

//////////////////
//PIPE: Execute - Memory
//////////////////

//MEM Logic


//MEM Module Declaration


//////////////////
//Writeback
//////////////////

WB wb_Test(clk, rst_n, mem_result, sprite_ALU_result, mem_ALU_select, //Inputs
		  reg_WB_data); //Outputs

	//input clk, rst_n, mem_ALU_select;
	//input [31:0] mem_result, sprite_ALU_result;
	//output [31:0] reg_WB_data;

//WB Stage Wire Declarations

//////////////////
//PIPE: Memory - Writeback
//////////////////

//WB Logic


//WB Module Declaration

endmodule
