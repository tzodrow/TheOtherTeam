module cpu_tb();
reg clk, rst_n;
wire hlt;
wire [21:0]pc;

cpu cpu_test(clk, rst_n, hlt, pc);

initial begin
clk = 0;
rst_n = 0;
#4;
rst_n = 1;

end

always #1 clk <= ~clk;


endmodule 