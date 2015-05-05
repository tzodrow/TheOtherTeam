`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////////////
// Company: UW Madison 
// Engineers: Tim Zodrow, Manjot S Pal, Jack
// 
// Create Date: 2/2/2015  
// Design Name: mini-spart
// Module Name: driver 
// Project Name: miniproject1
// Target Devices: FPGA
// Description: The driver starts initializes and drives the sparts transactions and receives
// data from the databus. It sets the baud rate from the br_cfg and sends out signals to 
// capture the data from the spart and send data back.

//////////////////////////////////////////////////////////////////////////////////////////////
module driver(
    input clk,
    input rst,
    input [1:0] br_cfg,
    output reg iocs,
    output reg iorw,
    input rda,
    input tbr,
    output reg [1:0] ioaddr,
    inout [7:0] databus
    );

	// SPART
	reg sel,wrt_rx_data;
	reg [3:0] state, nxt_state;
	reg [7:0] data_out, rx_data;
	
	reg inc_PC, dec_PC;
	wire [7:0] dst_reg_ID_EX_ascii;
	wire [7:0] dst_reg_EX_MEM_ascii;
	reg rst_instr_addr;
	
	// Tim's Testing Values
	reg [31:0] val0, val1, val2, val3, val4, val5, val6, val7, val8, val9, val10, val11, val12, val13, val14, val15;
	reg [31:0] val16, val17, val18, val19, val20, val21, val22, val23, val24, va25, val26, val127, val28, val29, val30, val31;
	reg [3:0] we_counter_tim;
	reg [2:0] hex_counter;
	reg rst_hex_counter, dec_hex_counter;
	reg [3:0] counter;
	
	localparam NUM_INSTRUCTIONS = 24'h000006;
	
	//////////////////////////////
	// States for State Machine //
	//////////////////////////////
	localparam INIT_LOW_DB = 4'b0000;
	localparam INIT_HIGH_DB = 4'b0001;
	localparam RECEIVE_WAIT = 4'b0010;
	localparam SEND_1 = 4'b0011;
	localparam SEND_2 = 4'b0100;
	localparam SEND_3 = 4'b0101;
	localparam SEND_4 = 4'b0110;
	localparam NEXT_LINE = 4'b0111;
	localparam PRINT_PC = 4'b1000;
	localparam SEND_LONG_HEX = 4'b1001;
	localparam SEND_SPACE = 4'b1010;
	localparam SEND_REG_FILE = 4'b1011;
	localparam SEND_REG_SPACE = 4'b1100;

	
	wire[31:0] IF_instr;
	wire[21:0] IF_PC, ID_is_branch, IF_next_PC;
	wire stall, flush, hlt;
	wire rst_n;
	
	reg re_hlt;
	reg [7:0] instr_counter;
	wire [21:0] instr_addr;
	wire [21:0] EX_PC, EX_PC_out;
	
	// Register File
	wire [31:0] regS_data, regT_data;
	
	//ID Stage Wire Declarations
	wire ID_hlt, ID_use_imm, ID_use_dst_reg;
	wire ID_update_neg, ID_update_carry, ID_update_ov, ID_update_zero;
	wire[2:0] ID_alu_opcode, ID_branch_conditions;
	wire[4:0] ID_dst_reg, ID_regS_addr, ID_regT_addr;
	wire[16:0] ID_imm; 
	wire[21:0] ID_PC, ID_PC_out, ID_branch_addr;
	wire[31:0] ID_instr;
	wire ID_mem_alu_select, ID_mem_we, ID_mem_re, ID_use_sprite_mem;
	wire[21:0] ID_return_PC_addr_reg;

	//sprite wires
	wire ID_sprite_use_imm, ID_sprite_re, ID_sprite_we, ID_sprite_use_dst_reg;
	wire[3:0] ID_sprite_action;
	wire[7:0] ID_sprite_addr;
	wire[13:0] ID_sprite_imm;
	
	wire IOR;
	
	wire EX_use_imm;
	wire EX_update_ov, EX_update_neg, EX_update_carry, EX_update_zero;
	wire EX_ov, EX_neg, EX_zero, EX_carry;
	wire [2:0] EX_alu_opcode, EX_branch_conditions;
	wire [16:0] EX_imm;
	wire [31:0] EX_s_data, EX_t_data, EX_ALU_result;
	wire [4:0] EX_dst_reg;
	// sprite wires
	wire EX_sprite_use_imm, EX_sprite_re, EX_sprite_we, EX_sprite_use_dst_reg, EX_mem_alu_select;
	wire [3:0] EX_sprite_action;
	wire [7:0] EX_sprite_addr;
	wire [13:0] EX_sprite_imm;
	wire [31:0] EX_sprite_data;
	
	wire MEM_sprite_ALU_select, MEM_mem_ALU_select, MEM_flag_ov, MEM_flag_neg, MEM_flag_zero, MEM_re, MEM_we, MEM_use_dst_reg, MEM_use_sprite_mem;
	wire [2:0] MEM_branch_cond;
	wire [4:0] MEM_addr, MEM_dst_reg;
	wire [21:0] MEM_PC, MEM_PC_out;
	wire [31:0] MEM_data, MEM_sprite_data, MEM_instr, MEM_sprite_ALU_result, MEM_mem_result, MEM_ALU_result, MEM_t_data;
	
	wire [21:0] WB_PC, WB_PC_out;
	wire [31:0] WB_mem_result, WB_sprite_ALU_result, WB_instr;
	wire WB_we;
	wire [4:0] WB_dst_reg;
	wire [31:0] WB_dst_reg_data_WB;
	wire [31:0] reg_WB_data;
	
	assign stall = ((MEM_dst_reg == ID_regS_addr || MEM_dst_reg == ID_regT_addr) && (MEM_dst_reg != 5'h00)) ? 1 :
		((EX_dst_reg == ID_regS_addr || EX_dst_reg == ID_regT_addr) && (EX_dst_reg != 5'h00)) ? 1 : 
		((WB_dst_reg == ID_regS_addr || WB_dst_reg == ID_regT_addr) && (WB_dst_reg != 5'h00)) ? 1 : 0;

	assign instr_addr = {{14{1'b0}}, instr_counter};
	assign dst_reg_EX_MEM_ascii = ({3'b000, MEM_dst_reg} + 8'h30);
	
	assign rst_n = ~rst;
	assign dst_reg_ID_EX_ascii = ({3'b000, EX_dst_reg} + 8'h30);
	// Tri-state buffer used to receive and send data via the databus
    // Sel high = output, Sel low = input
	assign databus = sel ? data_out : 8'bz;
	
	pc PC(
		.clk(clk),
		.rst_n(rst_n),
		.nxt_pc(IF_next_PC),
		.curr_pc(IF_PC));
	
	PC_MUX PC_MUX(
		.pc(IF_PC),
		.br_pc(ID_branch_addr),
		.taken(ID_is_branch),
		.halt(hlt),
		.stall(stall),
		.nxt_pc(IF_next_PC),
		.flush(flush));
	
	instr_fetch INSTR_FETCH(
		.clk(clk), 
		.hlt(hlt),
		.stall(stall),
		.addr(IF_PC), 
		.instr(IF_instr));
	
	//////////////////
	//PIPE: Instruction Fetch - Instruction Decode
	//////////////////
	IF_ID_pipeline_reg IF_ID_pipeline_Test(
		.clk(clk), 
		.rst_n(rst_n), 
		.hlt(hlt), 
		.stall(stall), 
		.flush(flush), 
		.IF_instr(IF_instr),
		.IF_PC(IF_PC), 
		.ID_instr(ID_instr), 
		.ID_PC(ID_PC));

	//ID Module Declaration
	instr_decode inst_decTest(
		.clk(clk), 
		.rst_n(rst_n), 
		.instr(IF_instr), 
		.alu_opcode(ID_alu_opcode), 
		.imm(ID_imm), 
		//.regS_data_ID(ID_s_data), 
		//.regT_data_ID(ID_t_data), 
		.use_imm(ID_use_imm),
		.use_dst_reg(ID_use_dst_reg), 
		.is_branch_instr(ID_is_branch), 
		.update_neg(ID_update_neg), 
		.update_carry(ID_update_carry), 
		.update_overflow(ID_update_ov), 
		.update_zero(ID_update_zero), 
		.sprite_addr(ID_sprite_addr), 
		.sprite_action(ID_sprite_action), 
		.sprite_use_imm(ID_sprite_use_imm), 
		.sprite_imm(ID_sprite_imm),
		.sprite_re(ID_sprite_re), 
		.sprite_we(ID_sprite_we), 
		.sprite_use_dst_reg(ID_sprite_use_dst_reg), 
		.IOR(IOR), 
		.dst_reg(ID_dst_reg), 
		.hlt(hlt),
		.PC_in(IF_PC), 
		.PC_out(ID_PC_out), 
		.dst_reg_WB(WB_dst_reg), 
		.dst_reg_data_WB(reg_WB_data), 
		.we(WB_use_dst_reg), 
		.branch_addr(ID_branch_addr), 
		.branch_conditions(ID_branch_conditions),
		.mem_alu_select(ID_mem_alu_select), 
		.mem_we(ID_mem_we), 
		.mem_re(ID_mem_re), 
		.use_sprite_mem(ID_use_sprite_mem), 
		.return_PC_addr_reg(ID_return_PC_addr_reg), 
		.next_PC(EX_PC_out),
		.re_hlt(re_hlt), 
		.addr_hlt(instr_counter[4:0]),
		.regS_addr(ID_regS_addr), 
		.regT_addr(ID_regT_addr),
		.EX_ov(EX_ov), 
		.EX_neg(EX_neg), 
		.EX_zero(EX_zero));
		
	reg_interface REG_FILE(
	   .clk(clk),
		.rst(rst),
		.we(WB_use_dst_reg),
		.regS_addr(ID_regS_addr),
		.regT_addr(ID_regT_addr),
		.regD_addr(WB_dst_reg),
		.regD_data(reg_WB_data),
		.regS_data(regS_data),
		.regT_data(regT_data));

	//////////////////
	//PIPE: Instruction Decode - Execute
	//////////////////
	ID_EX_pipeline_reg ID_EX_pipeline_Test(
		.clk(clk), 
		.rst_n(rst_n), 
		.stall(stall), 
		.hlt(hlt), 
		.flush(flush), 
		.ID_PC(ID_PC), 
		.ID_PC_out(ID_PC_out), 
		//.ID_s_data(ID_s_data), Remove These (Timing)
		//.ID_t_data(ID_t_data), Remove These (Timing)
		.ID_use_imm(ID_use_imm), 
		.ID_use_dst_reg(ID_use_dst_reg), 
		.ID_update_neg(ID_update_neg), 
		.ID_update_carry(ID_update_carry), 
		.ID_update_ov(ID_update_ov), 
		.ID_update_zero(ID_update_zero), 
		.ID_alu_opcode(ID_alu_opcode), 
		.ID_branch_conditions(ID_branch_conditions),
		.ID_imm(ID_imm), 
		.ID_dst_reg(ID_dst_reg), 
		.ID_sprite_addr(ID_sprite_addr), 
		.ID_sprite_action(ID_sprite_action), 
		.ID_sprite_use_imm(ID_sprite_use_imm), 
		.ID_sprite_re(ID_sprite_re), 
		.ID_sprite_we(ID_sprite_we), 
		.ID_sprite_use_dst_reg(ID_sprite_use_dst_reg), 
		.ID_sprite_imm(ID_sprite_imm), 
		.ID_mem_alu_select(ID_mem_alu_select), 
		.ID_mem_we(ID_mem_we), 
		.ID_mem_re(ID_mem_re), 
		.ID_use_sprite_mem(ID_use_sprite_mem), 
		.EX_PC(EX_PC), 
		.EX_PC_out(EX_PC_out), 
		//.EX_s_data(EX_s_data), Remove These (Timing)
		//.EX_t_data(EX_t_data), Remove These (Timing)
		.EX_use_imm(EX_use_imm), 
		.EX_use_dst_reg(EX_use_dst_reg), 
		.EX_update_neg(EX_update_neg), 
		.EX_update_carry(EX_update_carry), 
		.EX_update_ov(EX_update_ov), 
		.EX_update_zero(EX_update_zero), 
		.EX_alu_opcode(EX_alu_opcode), 
		.EX_branch_conditions(EX_branch_conditions),
		.EX_imm(EX_imm), 
		.EX_dst_reg(EX_dst_reg), 
		.EX_sprite_addr(EX_sprite_addr), 
		.EX_sprite_action(EX_sprite_action), 
		.EX_sprite_use_imm(EX_sprite_use_imm), 
		.EX_sprite_re(EX_sprite_re), 
		.EX_sprite_we(EX_sprite_we), 
		.EX_sprite_use_dst_reg(EX_sprite_use_dst_reg), 
		.EX_sprite_imm(EX_sprite_imm), 
		.EX_mem_alu_select(EX_mem_alu_select), 
		.EX_mem_we(EX_mem_we), 
		.EX_mem_re(EX_mem_re), 
		.EX_use_sprite_mem(EX_use_sprite_mem));
	
	//EX Module Declaration
	EX EX(
		.clk(clk), 
		.rst_n(rst_n), 
		.alu_opcode(EX_alu_opcode), 
		.update_flag_ov(EX_update_ov), 
		.update_flag_neg(EX_update_neg), 
		.update_flag_zero(EX_update_zero),
		.t_data(regT_data), 
		.s_data(regS_data), 
		.imm(EX_imm), 
		.use_imm(EX_use_imm), 
		.sprite_action(EX_sprite_action), 
		.sprite_imm(EX_sprite_imm), 
		.sprite_use_imm(EX_sprite_use_imm), 
		.sprite_addr(EX_sprite_addr),
		.sprite_re(EX_sprite_re), 
		.sprite_we(EX_sprite_we), 
		.sprite_use_dst_reg(EX_sprite_use_dst_reg),
		.ALU_result(EX_ALU_result), 
		.sprite_data(EX_sprite_data), 
		.flag_ov(EX_ov), 
		.flag_neg(EX_neg), 
		.flag_zero(EX_zero));
	
	//////////////////
	//PIPE: Execute - Memory
	//////////////////
	
	EX_MEM_pipeline_reg ex_mem_pipe_Test(
		.clk(clk), 
		.rst_n(rst_n), 
		.hlt(hlt), 
		.stall(stall), 
		.flush(flush), 
		.EX_ov(EX_ov), 
		.EX_neg(EX_neg), 
		.EX_zero(EX_zero), 
		.EX_use_dst_reg(EX_use_dst_reg), 
		.EX_branch_conditions(EX_branch_conditions), 
		.EX_dst_reg(EX_dst_reg), 
		.EX_PC(EX_PC), 
		.EX_PC_out(EX_PC_out),
		.EX_ALU_result(EX_ALU_result), 
		.EX_sprite_data(EX_sprite_data), 
		.EX_s_data(EX_s_data), 
		.EX_re(EX_mem_re), 
		.EX_we(EX_mem_we), 
		.EX_mem_ALU_select(EX_mem_alu_select), 
		.EX_use_sprite_mem(EX_use_sprite_mem), 
		.EX_t_data(EX_t_data),
		.MEM_sprite_ALU_select(MEM_sprite_ALU_select), 
		.MEM_mem_ALU_select(MEM_mem_ALU_select), 
		.MEM_flag_ov(MEM_flag_ov), 
		.MEM_flag_neg(MEM_flag_neg), 
		.MEM_flag_zero(MEM_flag_zero), 
		.MEM_re(ME_re), 
		.MEM_we(MEM_we), 
		.MEM_addr(MEM_addr), 
		.MEM_PC(MEM_PC), 
		.MEM_PC_out(MEM_PC_out), 
		.MEM_data(MEM_data), 
		.MEM_sprite_data(MEM_sprite_data),
		.MEM_branch_cond(MEM_branch_cond), 
		.MEM_use_dst_reg(MEM_use_dst_reg),
		.MEM_use_sprite_mem(MEM_use_sprite_mem), 
		.MEM_dst_reg(MEM_dst_reg), 
		.MEM_ALU_result(MEM_ALU_result), 
		.MEM_t_data(MEM_t_data)); 

	//////////////////
	//Memory
	//////////////////
	
	MEM mem_Test(
		.clk(clk), 
		.rst_n(rst_n), 
		.mem_data(MEM_t_data), 
		.addr(EX_ALU_result[21:0]), 
		.re(MEM_re), 
		.we(MEM_we), 
		.ALU_result(MEM_ALU_result), 
		.sprite_data(MEM_sprite_data), 
		.sprite_ALU_select(MEM_sprite_ALU_select), 
		.mem_ALU_select(mem_ALU_select), 
		.flag_ov(flag_ov), 
		.flag_neg(MEM_flag_neg), 
		.flag_zero(MEM_flag_zero), 
		.branch_condition(MEM_branch_cond),
	   .cache_hit(cache_hit),
		.sprite_ALU_result(MEM_sprite_ALU_result),
		.mem_result(MEM_mem_result), 
		.branch_taken(MEM_branch_taken));

	//////////////////
	//PIPE: Memory - Writeback
	//////////////////
	
	MEM_WB_pipeline_reg mem_wb_reg_testing(
		.clk(clk), 
		.rst_n(rst_n), 
		.hlt(hlt), 
		.stall(stall), 
		.flush(flush), 
		.MEM_mem_ALU_select(MEM_mem_ALU_select), 
		.MEM_PC(MEM_PC), 
		.MEM_PC_out(MEM_PC_out), 
		.MEM_ALU_result(MEM_sprite_ALU_result),  //TODO: Check the datapath for MEM_ALU_result
		.MEM_sprite_ALU_result(MEM_sprite_ALU_result), 
		.MEM_instr(MEM_instr), 
		.MEM_use_dst_reg(MEM_use_dst_reg), 
		.MEM_dst_reg(MEM_dst_reg), 
		.MEM_mem_result(MEM_mem_result),
		.WB_mem_ALU_select(WB_mem_ALU_select), 
		.WB_PC(WB_PC), 
		.WB_PC_out(WB_PC_out), 
		.WB_mem_result(WB_mem_result), 
		.WB_sprite_ALU_result(WB_sprite_ALU_result), 
		.WB_instr(WB_instr), 
		.WB_use_dst_reg(WB_use_dst_reg), 
		.WB_dst_reg(WB_dst_reg));
	
	//////////////////
	//Writeback
	//////////////////

	WB wb_Test(
		.clk(clk), 
		.rst_n(rst_n), 
		.mem_result(WB_mem_result), 
		.sprite_ALU_result(WB_sprite_ALU_result), 
		.mem_ALU_select(WB_mem_ALU_select), //Inputs
		.reg_WB_data(reg_WB_data)); //Outputs
	  
	always  @ (posedge clk, posedge rst) begin
		if(rst)
			instr_counter <= 8'h00;
		else if(rst_instr_addr)
			instr_counter <= 0;
		else if (inc_PC)
			instr_counter <= instr_counter + 1;
		else if (dec_PC)
			instr_counter <= instr_counter - 1;
	end
	
    // RX Received Data Flop
	always  @ (posedge clk, posedge rst) begin
		if(rst)
			rx_data <= 8'h00;
		else if (wrt_rx_data)
			rx_data <= databus;
	end
	
    // State Flop
	always @ (posedge clk, posedge rst) begin
		if(rst)
			state <= 2'b00;
		else
			state <= nxt_state;
	end
	
	always @ (posedge clk, posedge rst) begin
		if(rst)
			hex_counter <= 0;
		else if(rst_hex_counter)
			hex_counter <= 3'b111;
		else if(dec_hex_counter)
			hex_counter <= hex_counter - 1;
	end
	
	always @ (posedge clk, posedge rst) begin
		if(rst)
			counter <= 0;
		else if (~(&counter))
			counter <= counter + 1;
	end
	
	wire [31:0] value1, value2, value3;
	assign value1 = IF_instr;
	assign value2 = {IF_PC[11:0], 3'b0, stall, MEM_dst_reg[3:0], EX_dst_reg[3:0], ID_regS_addr[3:0], ID_regT_addr[3:0]};
	assign value3 = reg_WB_data;
	
	always @ (posedge clk, posedge rst) begin
		if(rst) begin
			val0 <= 0;
			val1 <= 0;
			val2 <= 0;
			val3 <= 0;
			val4 <= 0;
			val5 <= 0;
			val6 <= 0;
			val7 <= 0;
			val8 <= 0;
			val9 <= 0;
			val10 <= 0;
			val11 <= 0;
			val12 <= 0;
			val13 <= 0;
			val14 <= 0;
			val15 <= 0;
			val16 <= 0;
			val17 <= 0;
			val18 <= 0;
			val19 <= 0;
			val20 <= 0;
			val21 <= 0;
			val22 <= 0;
			val23 <= 0;
		end
		else if(~&counter) begin
			case(counter)
				5'h00 : begin
					val0 <= value1;
					val8 <= value2;
					val16 <= value3;
				end
				5'h01 : begin
					val1 <= value1;
					val9 <= value2;
					val17 <= value3;
				end
				5'h02 : begin
					val2 <= value1;
					val10 <= value2;
					val18 <= value3;
				end
				5'h03 : begin
					val3 <= value1;
					val11 <= value2;
					val19 <= value3;
				end
				5'h04 : begin
					val4 <= value1;
					val12 <= value2;
					val20 <= value3;
				end
				5'h05 : begin
					val5 <= value1;
					val13 <= value2;
					val21 <= value3;
				end
				5'h06 : begin
					val6 <= value1;
					val14 <= value2;
					val22 <= value3;
				end
				5'h07 : begin
					val7 <= value1;
					val15 <= value2;
					val23 <= value3;
				end
			endcase
		end
	end
	
	reg [31:0] hex_in;
	wire [7:0] ascii_out, instr_counter_ascii;
	
	always
		case(instr_counter)
			8'h00 : hex_in = val0 >> (hex_counter * 4);
			8'h01 : hex_in = val1 >> (hex_counter * 4);
			8'h02 : hex_in = val2 >> (hex_counter * 4);
			8'h03 : hex_in = val3 >> (hex_counter * 4);
			8'h04 : hex_in = val4 >> (hex_counter * 4);
			8'h05 : hex_in = val5 >> (hex_counter * 4);
			8'h06 : hex_in = val6 >> (hex_counter * 4);
			8'h07 : hex_in = val7 >> (hex_counter * 4);
			8'h08 : hex_in = val8 >> (hex_counter * 4);
			8'h09 : hex_in = val9 >> (hex_counter * 4);
			8'h0a : hex_in = val10 >> (hex_counter * 4);
			8'h0b : hex_in = val11 >> (hex_counter * 4);
			8'h0c : hex_in = val12 >> (hex_counter * 4);
			8'h0d : hex_in = val13 >> (hex_counter * 4);
			8'h0e : hex_in = val14 >> (hex_counter * 4);
			8'h0f : hex_in = val15 >> (hex_counter * 4);
			8'h10 : hex_in = val16 >> (hex_counter * 4);
			8'h11 : hex_in = val17 >> (hex_counter * 4);
			8'h12 : hex_in = val18 >> (hex_counter * 4);
			8'h13 : hex_in = val19 >> (hex_counter * 4);
			8'h14 : hex_in = val20 >> (hex_counter * 4);
			8'h15 : hex_in = val21 >> (hex_counter * 4);
			8'h16 : hex_in = val22 >> (hex_counter * 4);
			8'h17 : hex_in = val23 >> (hex_counter * 4);
			default : hex_in = 4'hf;
		endcase
		
	wire [31:0] reg_data;
	wire [7:0] reg_ascii;
	assign reg_data = regS_data >> (hex_counter * 4);
	
	
	hex2ascii data_ascii(.hex(hex_in[3:0]), .ascii(ascii_out));
	hex2ascii instr_ascii(.hex(instr_counter[3:0]), .ascii(instr_counter_ascii));
	hex2ascii reg_file_ascii(.hex(reg_data[3:0]), .ascii(reg_ascii));

	///////////////////
    // State Machine //
    ///////////////////
    always@(*) begin
        // Initializations
		ioaddr = 2'b00;
		sel = 0;
		iocs = 1;
		iorw = 1;
		nxt_state = INIT_LOW_DB;
		data_out = 8'h00;
		wrt_rx_data = 0;
		inc_PC = 0;
		dec_PC = 0;
		re_hlt = 0;
		rst_instr_addr = 0;
		rst_hex_counter = 0;
		dec_hex_counter = 0;
		
		case(state)
            // Write the lower byte to Baud Gen
			INIT_LOW_DB: begin 
					ioaddr = 2'b10;
					sel = 1;
					nxt_state = INIT_HIGH_DB;
					case(br_cfg)	
						2'b00: 
								data_out = 8'hc0;		//baud rate to 4800
						2'b01:
								data_out = 8'h80;		//baud rate to 9600	
						2'b10: 
								data_out = 8'h00;		//baud rate to 19200	
						2'b11:
								data_out = 8'h00;		//baud rate to 38400
					endcase	
			end
			// Write the higher byte to Baud Gen
			INIT_HIGH_DB: begin
					ioaddr = 2'b11;
					sel = 1;
					nxt_state = RECEIVE_WAIT;
					case(br_cfg)	
						2'b00: 
								data_out = 8'h12;		//baud rate to 4800
						2'b01:
								data_out = 8'h25;		//baud rate to 9600	
						2'b10: 
								data_out = 8'h4b;		//baud rate to 19200	
						2'b11:
								data_out = 8'h96;		//baud rate to 38400
					endcase	
			end
			// Wait for receive data to be read
			RECEIVE_WAIT: begin
					if(~rda) begin
						nxt_state = RECEIVE_WAIT;
						iocs = 0;
					end
					else begin
						if(databus == 8'h0d) begin //enter key
							nxt_state = SEND_1;
							ioaddr = 2'b00;
							re_hlt = 1;
							rst_instr_addr = 1;
							end
						else if(databus == 8'h31) begin	// '1' dec PC
							dec_PC = 1;
							nxt_state = PRINT_PC;
							ioaddr = 2'b00;
						end
						else if(databus == 8'h32) begin	// '2' inc PC
							inc_PC = 1;
							nxt_state = PRINT_PC;
							ioaddr = 2'b00;
						end
						else if(databus == 8'h20) begin
							nxt_state = SEND_LONG_HEX;
							ioaddr = 2'b00;
							rst_hex_counter = 1;
							rst_instr_addr = 1;
						end
						else if(databus == 8'h33) begin
							nxt_state = SEND_REG_FILE;
							ioaddr = 2'b00;
							rst_hex_counter = 1;
							rst_instr_addr = 1;
							re_hlt = 1;
						end
						else 
							nxt_state = RECEIVE_WAIT;
						
					end
			end

			// Send receive data to TX when TX is ready for data
			SEND_1: begin
				re_hlt = 1;	
				if (instr_addr >= 8'h06)
					nxt_state = RECEIVE_WAIT;
				else if(tbr) begin
					nxt_state = SEND_2;					
					ioaddr = 2'b00;
					iorw = 0;
					data_out = instr_counter_ascii;
					sel = 1;
				end
				else begin
					nxt_state = SEND_1;
				end
			end	

			SEND_2: begin
				re_hlt = 1;	
				if(tbr) begin
					nxt_state = NEXT_LINE;				
					ioaddr = 2'b00;
					iorw = 0;
					inc_PC = 1;
					data_out = ascii_out;
					sel = 1;
				end
				else begin
					nxt_state = SEND_2;
				end
				
			end	
			NEXT_LINE: begin
				re_hlt = 1;	
				if(tbr) begin
					nxt_state = SEND_1;					
					ioaddr = 2'b00;
					iorw = 0;
					data_out = 8'h20;
					sel = 1;
				end
				else begin
					nxt_state = NEXT_LINE;
				end
			end
							
			PRINT_PC: begin
				if(tbr) begin
					nxt_state = RECEIVE_WAIT;					
					ioaddr = 2'b00;
					iorw = 0;
					data_out = 8'h20;
					sel = 1;
				end
				else begin
					nxt_state = PRINT_PC;
				end
			end
			
			SEND_LONG_HEX : begin
				if(tbr) begin
					if(hex_counter == 3'b000)
						nxt_state = SEND_SPACE;
					else begin
						nxt_state = SEND_LONG_HEX;
						dec_hex_counter = 1;
					end
					ioaddr = 2'b00;
					iorw = 0;
					data_out = ascii_out;
					sel = 1;
				end
				else
					nxt_state = SEND_LONG_HEX;
			end
			
			SEND_SPACE : begin
				if(tbr) begin
					if(instr_counter >= 8'h17)
						nxt_state = RECEIVE_WAIT;
					else begin
						nxt_state = SEND_LONG_HEX;
						inc_PC = 1;
						rst_hex_counter = 1;
					end
					ioaddr = 2'b00;
					iorw = 0;
					data_out = 8'h20;
					sel = 1;
				end
				else
					nxt_state = SEND_SPACE;
			end
			
			SEND_REG_FILE : begin
				re_hlt = 1;
				if(tbr) begin
					if(hex_counter == 3'b000)
						nxt_state = SEND_REG_SPACE;
					else begin
						nxt_state = SEND_REG_FILE;
						dec_hex_counter = 1;
					end
					ioaddr = 2'b00;
					iorw = 0;
					data_out = reg_ascii;
					sel = 1;
				end
				else
					nxt_state = SEND_REG_FILE;
			end
			
			SEND_REG_SPACE : begin
				re_hlt = 1;
				if(tbr) begin
					if(instr_counter == 5'h1f)
						nxt_state = RECEIVE_WAIT;
					else begin
						nxt_state = SEND_REG_FILE;
						inc_PC = 1;
						rst_hex_counter = 1;
					end
					ioaddr = 2'b00;
					iorw = 0;
					data_out = 8'h20;
					sel = 1;
				end
				else
					nxt_state = SEND_REG_SPACE;
			end
			
		endcase
	end		
endmodule
