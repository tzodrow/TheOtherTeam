module ID_EX_tb();

reg clk,rst_n;
reg [31:0]instr;
reg [31:0]regS_data, regT_data; //reg data from the reg file

//reg [31:0] regT, regS;

wire hlt;

wire [4:0]regS_addr, regT_addr; //to the reg file 
wire [2:0]alu_opcode; //to pipleine reg for EX stage\
wire [16:0]imm; //to branch predictor and ID/EX pipeline reg
wire [31:0]regS_data_ID, regT_data_ID; 
wire [4:0] dst_reg; //sent down the pipeline for WB
wire use_imm; //asserted for any instruction which uses immediate values
wire use_dst_reg; //asserted if a destination reg is used
wire branch_instr; //sent to branch predictor to tell if a branch instr is decoded
wire reT, reS; //Reg read enable signals sent to the reg file

//control signals for EX to determine which flags to update 
wire update_sign, update_neg, update_carry, update_overflow, update_zero;


wire [7:0]sprite_addr; //tells EX which sprite it's accessing
wire [3:0]sprite_action;
wire sprite_use_imm;
wire [9:0]sprite_imm;
wire [4:0]sprite_reg;
wire sprite_re, sprite_we, sprite_use_dst_reg;
wire IOR;// use_alu; //read signal for spart

wire [31:0]rec_PC, ALU_result, sprite_data;
wire flag_ov, flag_sign, flag_zero, flag_carry;

instr_decode iDUT(clk,rst_n,instr, regS_data, regT_data, regS_addr, regT_addr, alu_opcode, imm, regS_data_ID, regT_data_ID, use_imm,
	  use_dst_reg, branch_instr, update_neg, update_carry, update_overflow, update_zero, sprite_addr, 
	  sprite_action, sprite_use_imm, sprite_imm, sprite_reg, sprite_re, sprite_we, sprite_use_dst_reg, IOR, dst_reg, reT, reS, hlt, 
	  PC_in, PC_out);

EX iEX(
	.PC(PC_out),
	.opcode(alu_opcode),
	.update_flag_ov(update_overflow),
	.update_flag_sign(update_neg),
	.update_flag_zero(update_zero),
	.update_flag_carry(update_carry),
	.t(regT_data_ID),
	.s(regS_data_ID),
	.imm(imm),
	.use_imm(use_imm),
	.dst_reg(dst_reg),
	.sprite_reg(sprite_reg),
	.sprite_fcn(sprite_action),
	.sprite_imm(sprite_imm),
	.sprite_use_imm(sprite_use_imm),
	.sprite_addr(sprite_addr),
	.sprite_re(sprite_re),
	.sprite_we(sprite_we),
	.sprite_use_dst_reg(sprite_use_dst_reg),

	.rec_PC(rec_PC),
	.ALU_result(ALU_result),
	.sprite_data(sprite_data),
	.flag_ov(flag_ov),
	.flag_sign(flag_sign),
	.flag_zero(flag_zero),
	.flag_carry(flag_carry)
	);
	

initial begin
clk = 0;
rst_n = 0;
instr = 32'h00119000;
regS_data = 32'd1;
regT_data = 32'd3;
#2;
rst_n = 1;
#2;
instr = 32'h38119000; //branch
//#2;
//instr = 32'h701ab067; //branch
//#2;
//instr = 32'hc01ab067; //TM

end

always #1 clk = ~clk;   

endmodule 
