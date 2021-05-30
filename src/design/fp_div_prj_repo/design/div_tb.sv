module newton_tb;
	logic [31:0] dividend; // dividend: .1xxx...x
	logic [31:0] divisor; // divisor: .1xxx...x
	logic start; // start
	logic clk, rst; // clock and reset
	logic [31:0] quotient; // quotient: x.xxx...x
	logic busy; // busy
	logic ready; // ready
	logic [1:0] count; // counter
	parameter SF_32 = 2.0**-32.0;  // Q0.32 scaling factor is 2^-32
	parameter SF_31 = 2.0**-31.0;  // Q1.31 scaling factor is 2^-31
	
	newton newton(dividend,divisor,start,clk,rst,quotient,busy,ready,count);
	
	initial 
		forever #10 clk = ~clk;

	
	initial begin
		$monitor("%d: %f / %f = %f, ready=%d", $time, dividend*SF_32, divisor*SF_32, quotient*SF_31, ready);
    end
	
	initial 
	begin
		clk = 1;
		rst = 0;
		#10 rst = 1;
		start = 0;
		dividend = 32'hc0000000;
		divisor = 32'h80000000;
		#20;
		start = 1;
		#20;
		start = 0;
		#100;
		dividend = 32'h00000000;
		divisor = 32'h00000000;		
		#20;
		start = 1;
		#20;
		start = 0;
		#10;
		#100;
		dividend = 32'h10000000;
		divisor = 32'h00000000;		
		#20;
		start = 1;
		#20;
		start = 0;
		#10;
	end
	
endmodule