module ms_counter_TB();
	reg clk, rst_n;
	reg prev_done;
	wire done;

	ms_counter iDUT(clk, rst_n, done);

	initial begin
		clk = 0;
		rst_n = 1;
		#3;
		rst_n = 0;
		#16;
		rst_n = 1;
		#1;
		#550000000;
		$stop;
	end
	always begin
		#5;
		clk = ~clk;
		if(done == 1) $display("Done signal raised");
	end
endmodule