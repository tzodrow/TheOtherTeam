module ALU(src0, src1, op, shamt, dst, ov, zr, neg);

	//I/O Ports
	input [15:0] src0, src1;
	input [3:0] shamt;
	input [2:0] op;
	output [15:0] dst;
	output ov, zr, neg;
  wire cout; 
  //Local
  wire [15:0] intermediate, src1Not, mathResult, shiftInter;
  localparam POSITIVE_SATURATION = 16'h7FFF;
  localparam NEGATIVE_SATURATION = 16'h8000;

  //Operations
  localparam OP_ADD = 3'b000;
  localparam OP_SUB = 3'b001;
  localparam OP_AND = 3'b010;
  localparam OP_NOR = 3'b011;
  localparam OP_SLL = 3'b100;
  localparam OP_SRL = 3'b101;
  localparam OP_SRA = 3'b110;
  localparam OP_LHB = 3'b111;
	
  //Get Bitwise NOT of SRC0 for subtraction
	assign src1Not = ~(src1);
	
	//Do math w/ saturation
	assign {cout, intermediate} =  (op == OP_ADD)	? (src0 + src1)		:   
						                   (op == OP_SUB)	?	(src1Not + src0 + 1)	: //carry in a 1 for subtraction and use negated src1
						                   {1'b0, 16'b0};   

    //determines if overflow occurred based on the MSBs of src0 and src1 and the results of the intermediate math op above
	assign	{ov, mathResult}		=	(op == OP_ADD) ? 
	                           (((src0[15] == src1[15]) && (src0[15] != intermediate[15]))	? 
	                               ((src1[15]) ? {1'b1, NEGATIVE_SATURATION} : {1'b1, POSITIVE_SATURATION}) :
	                               {1'b0, intermediate}) :
	                           (((src1Not[15] == src0[15]) && (src1Not[15] != intermediate[15]))	?
	                               ((src0[15]) ? {1'b1, NEGATIVE_SATURATION} : {1'b1, POSITIVE_SATURATION}) :
	                               {1'b0, intermediate});

    //if op was add or sub, just assign output to mathResult computed above
    // otherwise use the basic alu operations
	assign dst =	(op == OP_ADD || op == OP_SUB)	?	mathResult		:
			(op == OP_AND)			?	src1 & src0		:
			(op == OP_NOR)			?	~(src1 | src0)		:
			(op == OP_SLL)			?	src0 << shamt	:
			(op == OP_SRL)			?	src0 >> shamt	:
			(op == OP_SRA)			?	shiftInter : //$signed(src0) >>> shamt	:
			(op == OP_LHB)			?	{src1[7:0], src0[7:0]}	:   //immediate val is on src1  
										    dst;
	
	assign shiftInter = $signed(src0) >>> shamt; 	  //arithmetic shift

	assign zr = &(~dst);		//zero flag is all 0s
	
	assign neg = intermediate[15] ^ ov;	//negative if MSB xor Overflow

endmodule

//OLD TESTBENCH
/*module tALU;
  reg [15:0] src0, src1;
  reg[2:0] op;
  reg[3:0] shamt;
  reg[100:0] i; 
  wire [15:0] out; 
  wire ov, zr; 
  
  localparam DISPLAY_OVERFLOW = 1'b0;

  localparam ADD = 3'b000;
  localparam SUB = 3'b001;
  localparam AND = 3'b010;
  localparam NOR = 3'b011;
  localparam SLL = 3'b100;
  localparam SRL = 3'b101;
  localparam SRA = 3'b110;
  localparam LHB = 3'b111;
  
  ALU DUT(src0, src1, op, shamt, out, ov, zr);

  initial begin
    shamt = 1; 
    src0 = 16'h6666;
    src1 = 16'h0004;
    op = ADD;
    display;
    op = SUB;
    display;
    op = AND;
    display;
    op = NOR;
    display;
    op = SLL;
    display;
    op = SRL;
    display;
    op = SRA;
    display;
    op = LHB;
    display; 
    
    for(i = 0; i < 100000; i = i + 1) begin
      src0 = $random;
      src1 = $random;
      op = ADD;
      #5; 
      if(out != (src0 + src1) && (!ov))begin
          $display("Error");
          display;
          $stop;
      end
      if(ov && DISPLAY_OVERFLOW) display; 
      
      if(zr && (out != 0)) begin
        display;
        $display("Error");
        $stop;
      end  
    end 
    $display("ADD Passed"); 
    
    for(i = 0; i < 100000; i = i + 1) begin
      src0 = $random;
      src1 = $random;
      op = SUB;
      #5; 
      if(out != (src1 - src0) && (!ov))begin
          $display("Error");
          display;
          $stop;
      end
      if(ov && DISPLAY_OVERFLOW) display;
      
      if(zr && (out != 0)) begin
        display;
        $display("Error");
        $stop;
      end
        
    end 
    $display("SUB Passed");
  
    for(i = 0; i < 100000; i = i + 1) begin
      src0 = $random;
      src1 = $random;
      op = AND;
      #5; 
      if(out != (src1 & src0))begin
          $display("Error");
          display;
          $stop;
      end
      
      if(zr && (out != 0)) begin
        display;
        $display("Error");
        $stop;
      end
         
    end 
    $display("AND Passed");
    
    for(i = 0; i < 100000; i = i + 1) begin
      src0 = $random;
      src1 = $random;
      op = NOR;
      #5; 
      if(out != ~(src1 | src0))begin
          $display("Error");
          display;
          $stop;
      end
      
      if(zr && (out != 0)) begin
        display;
        $display("Error");
        $stop;
      end
         
    end 
    $display("NOR Passed");    
    
    for(i = 0; i < 100000; i = i + 1) begin
      src0 = $random;
      shamt = $random;
      op = SLL;
      #5; 
      if(out != (src0 << shamt))begin
          $display("Error");
          display;
          $stop;
      end
      
      if(zr && (out != 0)) begin
        display;
        $display("Error");
        $stop;
      end
         
    end 
    $display("SLL Passed");
    
    for(i = 0; i < 100000; i = i + 1) begin
      src0 = $random;
      shamt = $random;
      op = SRL;
      #5; 
      if(out != (src0 >> shamt))begin
          $display("Error");
          display;
          $stop;
      end
      
      if(zr && (out != 0)) begin
        display;
        $display("Error");
        $stop;
      end        
    end 
    $display("SRL Passed");
    
    for(i = 0; i < 100000; i = i + 1) begin
      src0 = $random;
      shamt = $random;
      op = SRA;
      #5; 
      if(out != (src0 >>> shamt))begin
          $display("Error");
          display;
          $stop;
      end
      if(zr && (out != 0)) begin
        display;
        $display("Error");
        $stop;
      end
         
    end 
    $display("SRA Passed");
    
    for(i = 0; i < 100000; i = i + 1) begin
      src0 = $random;
      src1 = $random;
      op = LHB;
      #5; 
      if(out != {src1[7:0], src0[7:0]})begin
          $display("Error");
          display;
          $stop;
      end
      if(zr && (out != 0)) begin
        display;
        $display("Error");
        $stop;
      end
         
    end 
    $display("LHB Passed");
    
  end
  
  task display;
    begin
      #5;
      $display("src0: %h src1: %h op: %b out: %h  ov: %b  zr: %b  shamt: %d", src0, src1, op, out, ov, zr, shamt);
    end
  endtask
endmodule
 */
