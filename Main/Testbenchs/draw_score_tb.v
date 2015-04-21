module draw_score_tb();

	reg clk ,rst_n, start, score_valid_data, frame_rdy;
	reg [31:0] score_data;
	wire done, score_re, frame_we;
	wire [4:0] score_addr;
	//17 bit value with new frame buffer
	wire [16:0] frame_addr;
	wire [31:0] frame_data;
	
	
	draw_score iDUT(.clk(clk), .rst_n(rst_n), .start(start), .score_data(score_data), .score_valid_data(score_valid_data), .frame_rdy(frame_rdy), //Inputs
					.done(done), .score_re(score_re), .score_addr(score_addr), .frame_addr(frame_addr), .frame_data(frame_data), .frame_we(frame_we)); //Outputs
	
	
	initial begin
		rst_n = 0;
		clk = 0;
		start = 0;
		score_valid_data = 0;
		frame_rdy = 0;
		score_data = 32'h00000010;
		
		repeat(2) @ (posedge clk);
		rst_n = 1;
		
		@(posedge clk);
		start = 1;
		
		@(posedge clk);
		start = 0;
		
		while(!done) begin
			repeat(5)@(posedge clk);
			score_valid_data = 1;
		
			@(posedge clk);
			score_valid_data = 0;
			
			repeat(5)@(posedge clk);
			frame_rdy = 1;
		end
	end 
	
	always@(done) begin
		if(done) begin
			$display("Test Passed");
			$stop;
		end
	end
	
	always 
		#5 clk <= ~clk;
		
endmodule