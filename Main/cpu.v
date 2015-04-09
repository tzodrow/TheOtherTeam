module cpu(input clk, input rst_n, output hlt, output[15:0] pc);

//////////////////
//Intruction Fetch
//////////////////

//IF Stage Wire Declarations


//IF Logic


//IF Module Declaration


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
