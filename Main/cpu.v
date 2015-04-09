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



//ID Logic


//ID Module Declaration
instr_decode(clk,rst_n, ID_instr, ID_alu_opcode, ID_imm, ID_s_data, ID_t_data, ID_use_imm,
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
