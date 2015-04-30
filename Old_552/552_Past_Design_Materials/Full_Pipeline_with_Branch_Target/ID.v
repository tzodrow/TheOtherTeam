//
//DECODE MODULE
//
module ID(clk, rst_n, hlt, instr, input_cntrl_reg_write, input_reg_write_addr, reg_write_data, pc,
	        p0_data, p1_data, immediate, jump_offset, alu_op, cntrl_branch_op, reg_write_addr, shamt,
	        cntrl_mem_write, cntrl_mem_read, cntrl_alu_src, cntrl_reg_write, cntrl_mem_to_reg, flag_set, jump_from_reg, cntrl_pc_src, cntrl_branch_instr, p0_addr, p1_addr, ID_hlt, re0, re1);
	        
	        input clk, rst_n, input_cntrl_reg_write, hlt;
	        input [3:0] input_reg_write_addr;
	        input [15:0] instr, reg_write_data, pc;
	        
	        output reg cntrl_mem_write, cntrl_mem_read, cntrl_alu_src, cntrl_reg_write, cntrl_mem_to_reg, jump_from_reg, cntrl_pc_src, cntrl_branch_instr, ID_hlt;
					output reg [1:0] flag_set;
	        output reg [2:0] alu_op, cntrl_branch_op;
	        output reg [3:0] reg_write_addr, shamt;
	        output reg [7:0] immediate;
	        output reg [11:0] jump_offset;
	        output [15:0] p0_data, p1_data;
					
					output reg [3:0] p0_addr, p1_addr;
					output reg re0, re1;

					localparam ADDc = 3'b000; //Local Params for sanity, func codes
					localparam SUBc = 3'b001;
					localparam ANDc = 3'b010;
					localparam NORc = 3'b011;
					localparam SLLc = 3'b100;
					localparam SRLc = 3'b101;
					localparam SRAc = 3'b110;
					localparam LHBc = 3'b111;
			
					localparam ADDi = 4'b0000; //Local Params for sanity, instruction codes
					localparam ADDZi = 4'b0001;
					localparam SUBi = 4'b0010;
					localparam ANDi = 4'b0011;
					localparam NORi = 4'b0100;
					localparam SLLi = 4'b0101;
					localparam SRLi = 4'b0110;
					localparam SRAi = 4'b0111;
					localparam LWi = 4'b1000;
					localparam SWi = 4'b1001;
					localparam LHBi = 4'b1010;
					localparam LLBi = 4'b1011;
					localparam Bi = 4'b1100;
					localparam JALi = 4'b1101;
					localparam JRi = 4'b1110;
					localparam HLTi = 4'b1111;


					rf  irf(.clk(clk),.p0_addr(p0_addr),.p1_addr(p1_addr),.p0(p0_data),.p1(p1_data),.re0(re0),.re1(re1),.dst_addr(input_reg_write_addr),.dst(reg_write_data),.we(input_cntrl_reg_write),.hlt(hlt));

					always @(*) begin
						//Set default values for outputs
						p0_addr = instr[7:4];   //reg addr 0 on bits 7-4
						p1_addr = instr[3:0];   //reg addr 1 on bits 3-0
						reg_write_addr = instr[11:8];   //writeback reg addr on 11-8
						re0 = 1;        //most ops will have these values
						re1 = 1;
						cntrl_reg_write	= 1;
						ID_hlt = 0;
						cntrl_alu_src = 0;
						shamt	= instr[3:0];
						alu_op = ADDc;
						immediate = instr[7:0];
						jump_offset = instr[11:0];
						flag_set = 2'b10;    //used in EX stage to determine which flags to set
						cntrl_mem_to_reg = 0;   //controls whether we are writing to reg from memory
						cntrl_mem_write = 0;    //writing to memory control
						cntrl_mem_read = 0;     //reading from memory control 
						cntrl_pc_src = 0;       //used for whether pc change is contained in instruction
						cntrl_branch_instr = 0;     
						cntrl_branch_op = instr[11:9];
						jump_from_reg = 0;      

						case(instr[15:12])
							ADDi	:	begin
											//presets all work for ADD
							end
							ADDZi	:	begin
								flag_set = 2'b11; //write only if zero flag is set.
							end									//May need to add logic for re0 and re1 in pipelined version for stalling
							SUBi	:	begin
								alu_op = SUBc;
							end
							ANDi	:	begin
								alu_op = ANDc;
								flag_set = 2'b01;   //only set certain flags
							end
							NORi	:	begin
								alu_op = NORc;
								flag_set = 2'b01;    //only set certain flags
							end
							SLLi	:	begin
								re1 = 1;
								alu_op = SLLc;
								flag_set = 2'b01;    //only set certain flags
							end
							SRLi	:	begin
								re1 = 0;        //only pull from one reg source in alu
								alu_op = SRLc;
								flag_set = 2'b01;    //only set certain flags
							end
							SRAi	:	begin
								re1 = 0;            //only pull from one reg source in alu
								alu_op = SRAc;
								flag_set = 2'b01;      //only set certain flags
							end
							LWi	:	begin
								re1 = 0;        //only pull from one reg source in alu
								cntrl_mem_to_reg = 1;
								cntrl_mem_read = 1;
								flag_set = 2'b00;       //only set certain flags
								immediate = {instr[3], instr[3], instr[3], instr[3], instr[3:0]};
								cntrl_alu_src = 1;      //only pull from one reg source in alu
							end
							SWi	:	begin
								cntrl_mem_write	= 1;
								cntrl_reg_write	= 0;    //don't store anything back in reg file
								cntrl_alu_src = 1;      //only pull from one reg source in alu
								flag_set = 2'b00;        //only set certain flags
								p1_addr = instr[11:8];
								immediate = {instr[3], instr[3], instr[3], instr[3], instr[3:0]};
							end
							LHBi	:	begin
								re1 = 0;            //only pull from one reg source in alu
								cntrl_alu_src = 1;      //only pull from one reg source in alu
								p0_addr = instr[11:8];
								alu_op = LHBc;
								flag_set = 2'b00;        //only set certain flags
							end
							LLBi	:	begin
								re1 = 0;            //only pull from one reg source in alu
								cntrl_alu_src = 1; //Select immediate with SE
								p0_addr = 0;
								flag_set = 2'b00;      //only set certain flags
							end
							Bi	:	begin
							  cntrl_pc_src = 1;       //pc is being changed potentially
							  cntrl_branch_instr = 1;   
								re0 = 0;        //no reg sources used in ALU
								re1 = 0;
								cntrl_alu_src = 1;      //select immediate
								jump_offset = {instr[8],instr[8],instr[8],instr[8:0]}; //sign extended immediate
								cntrl_reg_write	= 0;
								flag_set = 2'b00;     //only set certain flags
							end
							JALi	:	begin
							  cntrl_pc_src = 0;     //this is an unconditional jump that can be executed immediately, already handled in IF stage
								re0 = 0;        //no reg sources read in ALU
								re1 = 0;
								cntrl_alu_src = 1;         
								reg_write_addr = 4'b1111;  //set writeback reg to R15
								flag_set = 2'b00;       //only set certain flags
							end
							JRi	:	begin
							  cntrl_pc_src = 1;      //pc will be changed    
								re1 = 0;            //only pull from one reg source in alu
								jump_from_reg = 1;   //pc will take value from reg
								cntrl_reg_write	= 0;
								flag_set = 2'b00;        //only set certain flags
							end
							HLTi	:	begin
								re0 = 0;	//HALT!     
								re1 = 0;
								cntrl_reg_write	= 0;
								ID_hlt = 1;             //assert halt in ID
								flag_set = 2'b00;        //only set certain flags
							end
							default	:	begin
							end
						endcase


					end

endmodule
