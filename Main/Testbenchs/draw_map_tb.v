module draw_map_tb();


reg[80:0] i;

reg clk, rst, start;
wire done, frame_buf_we;
wire[16:0] frame_buf_addr;
wire[23:0] frame_buf_data;

draw_map draw_map(clk, rst, start, done,
               frame_buf_we, frame_buf_addr, frame_buf_data);

initial begin
	rst = 1;
	clk_pulse;
	rst = 0;
	clk_pulse;
	start = 1; 
	clk_pulse;
	start = 0;
   clk_pulse500000;
   $stop;
end


always@(done) begin
	if(done) $stop;
end

task clk_pulse;
begin
clk = 0;
#5;
clk = 1;
#5; 
clk = 0; 
#5;
end
endtask

task clk_pulse10;
begin
for(i =0; i < 10; i = i + 1) begin
	#5;
	clk = 0;
	#5;
	clk = 1; 
end
end
endtask

task clk_pulse500;
begin
for(i =0; i < 500; i = i + 1) begin
	#5;
	clk = 0;
	#5;
	clk = 1; 
end
end
endtask

task clk_pulse500000;
begin
for(i =0; i < 500000; i = i + 1) begin
	#5;
	clk = 0;
	#5;
	clk = 1; 
end
end
endtask



endmodule
