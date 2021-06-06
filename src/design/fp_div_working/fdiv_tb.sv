`timescale 1ns / 1ps

module fdiv_tb;
	logic [31:0] a, b;
	logic fdiv;
	logic [1:0] rm;
	logic ena;
	logic clk;
	logic clrn;
	logic [31:0] s;
	logic busy;
	logic stall;
	logic [4:0] count;
	logic [25:0] reg_x;
	logic [2:0] err_o;
	
	fdiv_newton fdiv_newton(a,b,rm,fdiv,ena,clk,clrn, s,busy,stall,count,reg_x,err_o);
	
	initial 
		forever #10 clk = ~clk;
	/*
	initial begin
		//$monitor("%d: %h / %h = %h, busy=%h, stall=%h, reg_x=%h",
		//$time, a, b, s, busy, stall, reg_x);
		$monitor("sign=%h, exponent=%h, fraction=%h, frac_plus_1=%h",
				fdiv_newton.sign, fdiv_newton.exponent, fdiv_newton.fraction, 
				fdiv_newton.frac_plus_1);
    end
	*/
	
	
	initial begin
		clk = 1'b1;
		clrn = 1'b0;
		#10 clrn = 1'b1;
		ena = 1'b1;
		fdiv = 1'b1;
		rm=2'b01;
		a = 32'h4100_0000;
		b = 32'h4080_0000;
		
		
		#350;
		a = 32'h0000_fe01;
		b = 32'h0000_00ff;
		
		#350;
		a=32'h4ac8_6898;
		b=32'hcb07_8682;
		
		#350
		a=32'h4ac8_6898;
		b=32'h0000_0000;
		
		#350;
		a=32'h0000_0000;
		b=32'hcb07_8682;
		
		#350;
		a=32'h0000_0000;
		b=32'h0000_0000;
		
	end
	
endmodule