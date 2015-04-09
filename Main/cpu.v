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
wire[21:0] ID_PC, ID_PC_out;
wire[31:0] ID_instr, ID_s_data, ID_t_data; 
wire ID_hlt, ID_use_imm, ID_use_dst_reg;
wire ID_update_neg, ID_update_carry, ID_update_ov, ID_update_zero; //flag updates
wire[2:0] ID_alu_opcode, ID_branch_conditions;
wire[16:0] ID_imm; 
wire[4:0] ID_dst_reg;

//sprite wires
wire[7:0] ID_sprite_addr;
wire[3:0] ID_sprite_action;
wire ID_sprite_use_imm, ID_sprite_re, ID_sprite_we, ID_sprite_use_dst_reg;
wire[13:0] ID_sprite_imm;

//SPART
wire 

//From WB Stage to Reg File in decode module
wire [4:0] WB_dst_reg_WB;
wire [31:0] WB_dst_reg_data_WB;
wire WB_we;


//////////////////
//PIPE: Instruction Fetch - Instruction Decode
//////////////////



//ID Logic


//ID Module Declaration
instr_decode(clk,rst_n, instr, alu_opcode, imm, regS_data_ID, regT_data_ID, use_imm,
	  use_dst_reg, branch_instr, update_neg, update_carry, update_overflow, update_zero, sprite_addr, 
	  sprite_action, sprite_use_imm, sprite_imm, /*sprite_reg_data,*/ sprite_re, sprite_we, sprite_use_dst_reg, IOR, dst_reg, hlt,
	  PC_in, PC_out, dst_reg_WB, dst_reg_data_WB, we);

//////////////////
//Execute
//////////////////

//EX Stage Wire Declarations

//////////////////
//PIPE: Instruction Decode - Execute
//////////////////

//EX Logic


//EX Module Declaration


//////////////////
//Memory
//////////////////

//MEM Stage Wire Declarations

//////////////////
//PIPE: Execute - Memory
//////////////////

//MEM Logic


//MEM Module Declaration


//////////////////
//Writeback
//////////////////

//WB Stage Wire Declarations

//////////////////
//PIPE: Memory - Writeback
//////////////////

//WB Logic


//WB Module Declaration


endmodule
