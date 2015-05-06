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

	reg sel,wrt_rx_data;
	wire[31:0] IF_instr;
	wire[21:0] IF_PC, IF_next_PC, pc;
	wire[4:0] ID_regS_addr, ID_regT_addr, MEM_dst_reg, EX_dst_reg;
	wire ID_is_branch;
	wire [4:0] WB_dst_reg;
	wire flush, hlt;
	wire stall;
	wire rst_n;
	wire ID_jr_instr, ID_sw_instr;
		//ID Stage Wire Declarations
	wire ID_use_imm, ID_use_dst_reg;
	wire ID_update_neg, ID_update_carry, ID_update_ov, ID_update_zero; //flag updates
	wire[2:0] ID_alu_opcode, ID_branch_conditions;
	wire[4:0] ID_dst_reg;
	wire[16:0] ID_imm; 
	
	wire[31:0] ID_instr, ID_s_data, ID_t_data; 
	wire ID_mem_ALU_select, ID_mem_we, ID_mem_re, ID_use_sprite_mem;

	//sprite wires
	wire ID_sprite_use_imm, ID_sprite_re, ID_sprite_we, ID_sprite_use_dst_reg;
	wire[3:0] ID_sprite_action;
	wire[7:0] ID_sprite_addr;
	wire[13:0] ID_sprite_imm;

	wire ID_hlt, EX_hlt, MEM_hlt, WB_hlt;

	reg[4:0]hlt_mem_addr;
	reg inc_mem_addr;

	//SPART
	wire IOR;

	//From WB Stage to Reg File in decode module
	wire WB_we;
	wire [31:0] WB_dst_reg_data_WB;
	wire [31:0] reg_WB_data;
	wire ID_flush;
	assign flush = 0;
	
	assign stall = (ID_use_dst_reg && ((MEM_dst_reg == ID_regS_addr || MEM_dst_reg == ID_regT_addr) || 
												    (EX_dst_reg == ID_regS_addr || EX_dst_reg == ID_regT_addr) ||
													 (WB_dst_reg == ID_regS_addr || WB_dst_reg == ID_regT_addr))) ? 1 : 
						(ID_jr_instr && ((MEM_dst_reg == ID_regS_addr) || (EX_dst_reg == ID_regS_addr) || (WB_dst_reg == ID_regS_addr))) ? 1:							
						(ID_sw_instr && ((MEM_dst_reg == ID_regT_addr) || (EX_dst_reg == ID_regT_addr) || (WB_dst_reg == ID_regT_addr))) ? 1: 1'b0;							
	
	wire IF_instr_mem_re;
	
	wire[21:0] ID_PC, ID_PC_out, ID_branch_addr;
	
	assign pc = IF_PC;
	
	pc PC(clk, rst_n, IF_next_PC, IF_PC);

	
	assign IF_instr_mem_re = ~stall; 	
	assign IF_next_PC = (stall | hlt) ? IF_PC :  
							  (ID_is_branch) ? ID_branch_addr[7:0] :
							   IF_PC + 1;

	
	assign ID_flush = (ID_is_branch) ? 1 : 0;
	
	//////CHANGE LATER

	//assign hlt = 0;
	//assign stall = ~wrt_rx_data;
	
	
	//IF THERE ARE TIMING ISSUES, STANDARDIZE ALL RESETS
	assign rst_n = ~rst;




    //////////////////////////////
    // States for State Machine //
    //////////////////////////////
    localparam INIT_LOW_DB = 4'b0000;
    localparam INIT_HIGH_DB = 4'b0001;
    localparam RECEIVE_WAIT = 4'b0010;
    localparam SEND_1 = 4'b0011;
	 localparam SEND_2 = 4'b0100;
	 localparam PRINT_MEMORY = 4'b0101;
	 localparam SEND_4 = 4'b0110;
	 localparam NEXT_LINE = 4'b0111;
	 localparam PRINT_PC = 4'b1000;
    ////////////////////////////////////////
    // Registers used for control signals //
    ////////////////////////////////////////
    
    // State Registers
    reg [3:0] state, nxt_state;
    // Data Registers
    reg [7:0] data_out, rx_data;
	 reg re_hlt;
	reg inc_PC, dec_PC;
	reg[7:0] instr_counter;
	wire [21:0]instr_addr;
	wire [21:0] EX_PC, EX_PC_out;
	
	assign instr_addr = {{14{1'b0}}, instr_counter};
	
	instr_fetch instr_fetch(.clk(clk), .rst_n(rst_n), .re(IF_instr_mem_re), .addr(pc), .instr(IF_instr));
	
	wire [7:0]ascii_PC;
	assign ascii_PC = (instr_addr[7:0] + 8'h30);
	

	//////////////////
//PIPE: Instruction Fetch - Instruction Decode
//////////////////
IF_ID_pipeline_reg IF_ID_pipeline_Test(.clk(clk), .rst_n(rst_n), .hlt(ID_hlt), .stall(stall), .flush(ID_flush), .IF_instr(IF_instr), .ID_instr(ID_instr), .IF_PC(IF_PC), .ID_PC(ID_PC));

wire[21:0] ID_return_PC_addr_reg;

//ID Module Declaration
instr_decode inst_decTest(.clk(clk), .rst_n(rst_n), .instr(ID_instr), .alu_opcode(ID_alu_opcode), .imm(ID_imm), .regS_data_ID(ID_s_data), .regT_data_ID(ID_t_data), .use_imm(ID_use_imm),
	  .use_dst_reg(ID_use_dst_reg), .is_branch_instr(ID_is_branch), .update_neg(ID_update_neg), .update_carry(ID_update_carry), .update_overflow(ID_update_ov), 
	  .update_zero(ID_update_zero), .sprite_addr(ID_sprite_addr), .sprite_action(ID_sprite_action), .sprite_use_imm(ID_sprite_use_imm), .sprite_imm(ID_sprite_imm),
	  .sprite_re(ID_sprite_re), .sprite_we(ID_sprite_we), .sprite_use_dst_reg(ID_sprite_use_dst_reg), .IOR(IOR), .dst_reg(ID_dst_reg), .hlt(ID_hlt),
	  .PC_in(ID_PC), .PC_out(ID_PC_out), .dst_reg_WB(WB_dst_reg), .dst_reg_data_WB(reg_WB_data), .we(WB_use_dst_reg), .branch_addr(ID_branch_addr), .branch_conditions(ID_branch_conditions),
	  .mem_alu_select(ID_mem_ALU_select), .mem_we(ID_mem_we), .mem_re(ID_mem_re), .use_sprite_mem(ID_use_sprite_mem), .return_PC_addr_reg(ID_return_PC_addr_reg), .next_PC(EX_PC_out),
	  .re_hlt(re_hlt), .addr_hlt(instr_counter[4:0]), .regS_addr(ID_regS_addr), .regT_addr(ID_regT_addr), .stall(stall), .jr_instr(ID_jr_instr), .sw_instr(ID_sw_instr));
	  

wire [7:0] s_data_ascii;
assign s_data_ascii = (ID_s_data[7:0] + 8'h30);	 
wire [7:0] instr_counter_ascii;
assign instr_counter_ascii = (instr_counter[7:0] + 8'h30);	 
//wire [7:0] dst_reg_ID_ascii, dst_reg_ID_data_ascii, ID_we_ascii, data_S_ascii, ID_return_PC_addr_reg_ascii, ID_branch_addr_ascii;

//assign ID_branch_addr_ascii = (ID_branch_addr[7:0] + 8'h30);
//assign ID_return_PC_addr_reg_ascii = (ID_return_PC_addr_reg[7:0] + 8'h30);
//assign dst_reg_ID_ascii = ({3'b000, WB_dst_reg} + 8'h30);	  
//assign dst_reg_ID_data_ascii = (reg_WB_data + 8'h30);	
 
//assign ID_imm_ascii = (ID_imm[7:0] + 8'h30);
//assign data_S_ascii = (ID_s_data[7:0] + 8'h30);
//////////////////
//Execute
//////////////////

//EX Stage Wire Declarations

wire EX_use_imm;
wire EX_update_ov, EX_update_neg, EX_update_carry, EX_update_zero;
wire EX_ov, EX_neg, EX_zero, EX_carry;
wire [2:0] EX_alu_opcode, EX_branch_conditions;
wire [16:0] EX_imm;
wire [31:0] EX_s_data, EX_t_data, EX_ALU_result;
//sprite wires
wire EX_sprite_use_imm, EX_sprite_re, EX_sprite_we, EX_sprite_use_dst_reg, EX_mem_ALU_select;
wire [3:0] EX_sprite_action;
wire [7:0] EX_sprite_addr;
wire [13:0] EX_sprite_imm;
wire [31:0] EX_sprite_data;


//////////////////
//PIPE: Instruction Decode - Execute
//////////////////


ID_EX_pipeline_reg ID_EX_pipeline_Test(clk, rst_n, stall, ID_hlt, flush, ID_PC, ID_PC_out, ID_use_imm, 
	ID_use_dst_reg, ID_update_neg, ID_update_carry, ID_update_ov, ID_update_zero, ID_alu_opcode, ID_branch_conditions,
	ID_imm, ID_dst_reg, ID_sprite_addr, ID_sprite_action, ID_sprite_use_imm, ID_sprite_re, ID_sprite_we, 
	ID_sprite_use_dst_reg, ID_sprite_imm, ID_mem_ALU_select, ID_mem_we, ID_mem_re, ID_use_sprite_mem, EX_PC, EX_PC_out, EX_use_imm, 
	EX_use_dst_reg, EX_update_neg, EX_update_carry, EX_update_ov, EX_update_zero, EX_alu_opcode, EX_branch_conditions,
	EX_imm, EX_dst_reg, EX_sprite_addr, EX_sprite_action, EX_sprite_use_imm, EX_sprite_re, EX_sprite_we, 
	EX_sprite_use_dst_reg, EX_sprite_imm, EX_mem_ALU_select, EX_mem_we, EX_mem_re, EX_use_sprite_mem, EX_hlt);

//EX Logic

wire [7:0] dst_reg_ID_EX_ascii;
assign dst_reg_ID_EX_ascii = ({3'b000, EX_dst_reg} + 8'h30);


//EX Module Declaration
EX EX(.clk(clk), .rst_n(rst_n), .alu_opcode(EX_alu_opcode), .update_flag_ov(EX_update_ov), .update_flag_neg(EX_update_neg), .update_flag_zero(EX_update_zero), /*.update_flag_carry(EX_update_carry),*/
      .t_data(ID_t_data), .s_data(ID_s_data), .imm(EX_imm), .use_imm(EX_use_imm), .sprite_action(EX_sprite_action), .sprite_imm(EX_sprite_imm), 
	   .sprite_use_imm(EX_sprite_use_imm), .sprite_addr(EX_sprite_addr),.sprite_re(EX_sprite_re), .sprite_we(EX_sprite_we), .sprite_use_dst_reg(EX_sprite_use_dst_reg), // < ^inputs 
	   .ALU_result(EX_ALU_result), .sprite_data(EX_sprite_data), .flag_ov(EX_ov), .flag_neg(EX_neg), .flag_zero(EX_zero) /*.flag_carry(EX_carry)*/ //outputs
	);
//MEM Stage Wire Declarations

wire MEM_sprite_ALU_select, MEM_mem_ALU_select, MEM_flag_ov, MEM_flag_neg, MEM_flag_zero, MEM_re, MEM_we, MEM_use_dst_reg, MEM_use_sprite_mem;
wire [2:0] MEM_branch_cond;
wire [4:0] MEM_addr;
wire [21:0] MEM_PC, MEM_PC_out;
wire [31:0] MEM_data, MEM_sprite_data, MEM_instr, MEM_sprite_ALU_result, MEM_mem_result, MEM_ALU_result, MEM_t_data;

//////////////////
//PIPE: Execute - Memory
//////////////////

EX_MEM_pipeline_reg ex_mem_pipe_Test(clk, rst_n, EX_hlt, stall, flush, EX_ov, EX_neg, EX_zero, EX_use_dst_reg, EX_branch_conditions, EX_dst_reg, EX_PC, EX_PC_out, EX_ALU_result, EX_sprite_data,
				     EX_s_data, EX_mem_re, EX_mem_we, EX_mem_ALU_select, EX_use_sprite_mem, EX_t_data, //Inputs
				     MEM_sprite_ALU_select, MEM_mem_ALU_select, MEM_flag_ov, MEM_flag_neg, MEM_flag_zero, 
				     MEM_re, MEM_we, MEM_addr, MEM_PC, MEM_PC_out, MEM_data, MEM_sprite_data, /*MEM_instr,*/ MEM_branch_cond, MEM_use_dst_reg,
				     MEM_use_sprite_mem, MEM_dst_reg, MEM_ALU_result, MEM_t_data, MEM_hlt);

wire [7:0] dst_reg_EX_MEM_ascii;
assign dst_reg_EX_MEM_ascii = ({3'b000, MEM_dst_reg} + 8'h30);
//MEM Logic


//MEM Module Declaration


//////////////////
//Memory
//////////////////


wire [21:0] WB_PC, WB_PC_out;
wire [31:0] WB_mem_result, WB_sprite_ALU_result, WB_instr; 


MEM mem_Test(.clk(clk), .rst_n(rst_n), .mem_data(MEM_t_data), .addr(EX_ALU_result[21:0]), .re(MEM_re), .we(MEM_we), .ALU_result(MEM_ALU_result), .sprite_data(MEM_sprite_data), 
	     .sprite_ALU_select(MEM_sprite_ALU_select), .mem_ALU_select(mem_ALU_select), .flag_ov(flag_ov), 
	     .flag_neg(MEM_flag_neg), .flag_zero(MEM_flag_zero), .branch_condition(MEM_branch_cond), //Inputs
             .cache_hit(cache_hit), /*.mem_ALU_WB_select(MEM_mem_ALU_select),*/ .sprite_ALU_result(MEM_sprite_ALU_result),
	     .mem_result(MEM_mem_result), .branch_taken(MEM_branch_taken), .hlt(MEM_hlt), .hlt_mem_addr(hlt_mem_addr)); //Outputs

//NOTE: MEM_ALU_result may not be hooked up properly

		   
//WB Stage Wire Declarations

//////////////////
//PIPE: Memory - Writeback
//////////////////

MEM_WB_pipeline_reg mem_wb_pipe_Test(clk, rst_n, MEM_hlt, stall, flush, MEM_mem_ALU_select, MEM_PC, MEM_PC_out,MEM_ALU_result, MEM_sprite_ALU_result,MEM_instr,MEM_use_dst_reg, MEM_dst_reg, MEM_mem_result, //Inputs
				     WB_mem_ALU_select, WB_PC, WB_PC_out, WB_mem_result, WB_sprite_ALU_result, WB_instr, WB_use_dst_reg, WB_dst_reg, WB_hlt);  //Outputs


//WB Logic

wire [7:0] mem_ascii;
assign mem_ascii = (MEM_mem_result[7:0] + 8'h30); //convert to ascii

//WB Module Declaration

//////////////////
//Writeback
//////////////////


WB wb_Test(.clk(clk), .rst_n(rst_n), .mem_result(WB_mem_result), .sprite_ALU_result(WB_sprite_ALU_result), .mem_ALU_select(WB_mem_ALU_select), //Inputs
		  .reg_WB_data(reg_WB_data)); //Outputs

//wire [7:0]dst_reg_data_ascii, dst_reg_data_muxin_ascii, mem_result_ascii, control_ascii;
//assign dst_reg_data_muxin_ascii = (WB_sprite_ALU_result[7:0] + 8'h30); //2
//assign dst_reg_data_ascii = (reg_WB_data[7:0] + 8'h30); //0
//assign mem_result_ascii = (WB_mem_result[7:0] + 8'h30);  //0
//assign control_ascii = ({7'd0, WB_mem_ALU_select} + 8'h30);  //0
	  
	always  @ (posedge clk, posedge rst) begin
		if(rst)
			instr_counter <= 8'h00;
		else if (inc_PC)
			instr_counter <= instr_counter + 1;
		else if (dec_PC)
			instr_counter <= instr_counter - 1;	
		//else if (ID_is_branch)
			//instr_counter <= ID_branch_addr[7:0];
	end
	
	always  @ (posedge clk, posedge rst) begin
		if(rst)
			hlt_mem_addr <= 5'h00;
		else if (inc_mem_addr)
			hlt_mem_addr <= hlt_mem_addr + 1;

	end
    // Tri-state buffer used to receive and send data via the databuse
    // Sel high = output, Sel low = input
	assign databus = sel ? data_out : 8'bz;
	
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
		inc_mem_addr = 0;
		
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
						/*
						if(hlt) begin //enter key
							nxt_state = SEND_1;
							ioaddr = 2'b00;
							//wrt_rx_data = 1;
						end
						*/
						if(databus == 8'h0d) begin //enter key
							nxt_state = SEND_1;
							ioaddr = 2'b00;
							re_hlt = 1;	
							//wrt_rx_data = 1;
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
						else 
							nxt_state = RECEIVE_WAIT;
						
					end
			end

			// Send receive data to TX when TX is ready for data
			SEND_1: begin
				re_hlt = 1;	
				if (instr_addr >= 8'h0a)
					nxt_state = PRINT_MEMORY;
				else if(tbr) begin
					nxt_state = SEND_2;					
					ioaddr = 2'b00;
					iorw = 0;
					data_out = instr_counter_ascii;
				  //re_hlt = 1;	
					//data_out = IF_instr[7:0];
					//data_out = dst_reg_ID_data_ascii;
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
					//data_out = rx_data;
					//data_out = IF_instr[15:8];
					//data_out = ID_branch_addr_ascii;//dst_reg_ID_ascii;//dst_reg_data_ascii;
					re_hlt = 1;
					data_out = s_data_ascii;
					sel = 1;
				end
				else begin
					nxt_state = SEND_2;
				end
				
			end	
					
			PRINT_MEMORY: begin
				if(hlt_mem_addr >= 5'h0a)
					nxt_state = RECEIVE_WAIT;
				else if(tbr) begin
					inc_mem_addr = 1;
					nxt_state = NEXT_LINE;					
					ioaddr = 2'b00;
					iorw = 0;
					//data_out = rx_data;
					//data_out = IF_instr[23:16];
					data_out = mem_ascii;
					sel = 1;
				end
				else begin
					nxt_state = PRINT_MEMORY;
				end
			end
			/*
			SEND_4: begin
				if(tbr) begin
					nxt_state = NEXT_LINE;					
					ioaddr = 2'b00;
					iorw = 0;
					//data_out = rx_data;
					//data_out = IF_instr[31:24];
					data_out = ascii_PC; //control_ascii;
					sel = 1;
					wrt_rx_data = 1;
				end
				else begin
					nxt_state = SEND_4;
				end
			end
			*/	
			NEXT_LINE: begin
				re_hlt = 1;	
				if(tbr) begin
					if(hlt_mem_addr == 5'h00)
						nxt_state = SEND_1;
					else
						nxt_state = PRINT_MEMORY;
						
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
					data_out = 8'h20;//ascii_PC;
					sel = 1;
				end
				else begin
					nxt_state = PRINT_PC;
				end
			end
			
		endcase
	end		
endmodule
