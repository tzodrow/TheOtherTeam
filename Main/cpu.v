module cpu(input clk, input rst_n, output hlt, output[21:0] pc);

//system-wide declarations 
wire stall; 


//system-wide assigns 


//////////////////
//Intruction Fetch
//////////////////

//IF Stage Wire Declarations
wire IF_instr_mem_re;
wire[21:0] IF_pc, IF_next_pc;
wire[31:0] IF_instr;

//IF Logic
assign pc = IF_pc;

pc PC(clk, rst_n, IF_nxt_pc, IF_pc);

assign IF_instr_mem_re = ~stall; 	
assign IF_nxt_pc = IF_pc + 1; //ADD logic for branching

//IF Module Declaration
instr_fetch instr_fetch(clk, rst_n, IF_instr_mem_re, IF_pc, IF_instr);

//////////////////
//PIPE: Instruction Fetch - Instruction Decode
//////////////////





//////////////////
//Instruction Decode
//////////////////

//ID Stage Wire Declarations


//ID Logic


//ID Module Declaration


//////////////////
//PIPE: Instruction Decode - Execute
//////////////////





//////////////////
//Execute
//////////////////

//EX Stage Wire Declarations


//EX Logic


//EX Module Declaration


//////////////////
//PIPE: Execute - Memory
//////////////////





//////////////////
//Memory
//////////////////

//MEM Stage Wire Declarations


//MEM Logic


//MEM Module Declaration


//////////////////
//PIPE: Memory - Writeback
//////////////////





//////////////////
//Writeback
//////////////////

//WB Stage Wire Declarations


//WB Logic


//WB Module Declaration


endmodule
