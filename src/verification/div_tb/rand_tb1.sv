`timescale 1ns / 1ps

import fp_pkg::*;

module top;
	parameter NTEST= 1;
	typedef enum logic[1:0] {
		ADD, SUB, MUL, DIV
	} op_choice;

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
	
	o_err_t exp_err, err_o;
	
	fdiv_newton fdiv_newton(a,b,rm,fdiv,ena,clk,clrn, s,busy,stall,count,reg_x,err_o);
	
	//define class handlers
	FloatingPoint op1, op2, out, exp; 
	
	//define enum variables for the type of inputs
	fp_case op1_case, op2_case;
	bit op1_sign, op2_sign;
	op_choice choice;
	
	//error count
	int err_count, test_count;
	
	//sign bit change variables
	logic [1:0] sign_tc; //{op1_sign, op2_sign}
	
	task automatic divideTestCaseGenerator(input fp_case op1_case, op2_case, bit op1_sign, op2_sign, op_choice choice);
			//pass by ref for operand1, 2, expected result and actual output
			//FloatingPoint op1, op2, exp, out;
			//generate random input for operand 1
			op1.generateNew(op1_case);
			//generate random input for operand 2
			op2.generateNew(op2_case);
			//set the sign for operand 1
			op1.setSign(op1_sign);
			//set the sign for operand 2
			op2.setSign(op2_sign);
			
			//get the expected result for each operation
			unique case (choice)
				ADD: exp.setSR(op1.getSR + op2.getSR);
				SUB: exp.setSR(op1.getSR - op2.getSR);
				MUL: exp.setSR(op1.getSR * op2.getSR);
				DIV: exp.setSR(op1.getSR / op2.getSR);
			endcase
			
			//get the expected error code
			exp_err = expectedErrorCode(exp);
			
			//set the random inputs generated to the design
	
			a= {op1.sign, op1.exponent, op1.significand};
			b= {op2.sign, op2.exponent, op2.significand};
			
			/*
			`ifdef DEBUG
				$display("%0t:a=%0h %0e, b=%0h %0e, s=%0h %0e, OP1=%0h, OP2=%0h, OUT=%0h, EXP=%0h, RES=%0e, EXP_TYPE=%0s, RES_TYPE=%0s", $time, a, op1.getSR(), b, op1.getSR(), s, s, op1.getSR(), op2.getSR(), out.getSR(), exp.getSR(), out.op_case.name(), exp_err.name(), err_o.name());
			`endif
			*/
			#150;
			/*
			if(err_o !== exp_err) begin
					$display("%0t: ERROR CODE MISMATCH: OP1=%0e %0h %0s, OP2=%0e %0h %0s, OPTION: =%0h, EXP_ERR=%0s, RES_ERR=%0s ",
							$time, op1.getSR(), $shortrealtobits(op1.getSR()), op1.op_case.name(), op2.getSR(), $shortrealtobits(op2.getSR()), op2.op_case.name(), choice, exp_err.name(), err_o.name());
				end
				*/
			#150;
			out.setBits(s);
			if(count == 5'h10) begin
				if(!out.equals(exp)) begin
					$display("%0t:: VALUE/TYPE MISMATCH: OP1=%0e %0s %0h, OP2=%0e %0s %0h, OPTION=%0h, EXP=%0h %0e, RES=%0h %0e, EXP_TYPE=%0s, RES_TYPE=%0s",
						$time, op1.getSR(), op1.op_case.name(), $shortrealtobits(op1.getSR()), op2.getSR(), op2.op_case.name(), $shortrealtobits(op2.getSR()), choice, $shortrealtobits(exp.getSR()), exp.getSR(), $shortrealtobits(out.getSR()), out.getSR(), exp.op_case.name(), out.op_case.name() );
					
				end
			`ifdef DEBUG
				$display("%0t:a=%0e %0e, b=%0e %0e, s=%0e %0h , OUT=%0e, EXP=%0e %0h, OUT_TYPE=%0e, EXP_TYPE=%0s, choice=%h, MANUAL=%0e %f", 
							$time, $bitstoshortreal(a), op1.getSR(), $bitstoshortreal(b), op2.getSR(), $bitstoshortreal(s), s, $shortrealtobits(out.getSR()), $shortrealtobits(exp.getSR()), $shortrealtobits(exp.getSR()), out.op_case.name(), exp.op_case.name(), choice, op2.getSR / op2.getSR, op2.getSR / op2.getSR);
			`endif
			
				test_count++;
			end
	endtask
	
	initial 
		forever #10 clk = ~clk;
		
	initial begin
		
		//define object for operands and the outputs
		op1 = new();	//operand 1
		op2 = new();	//operand 2
		out = new();	//output
		exp = new();	//expected output
		
		op1_case = op1_case.first;
		op2_case = op2_case.first;

		
		//select the choice of input operation: add, sub, mul, div
		
		//clk
		clk = 1'b0;
		//reset
		clrn = 1'b0;
		#10 clrn = 1'b1;
		ena = 1'b1;
		fdiv = 1'b1;
		rm = 2'b0;
		sign_tc = 0;
		choice = DIV;
		divideTestCaseGenerator(op1_case, op2_case, sign_tc[1], sign_tc[0], choice);
		
		do begin
			do begin
					for(sign_tc = 0; sign_tc < 4; sign_tc++) begin
						for(int i=0; i<NTEST; i++) begin
							divideTestCaseGenerator(op1_case, op2_case, sign_tc[1], sign_tc[0], choice);
					end
				end
				op2_case = op2_case.next;
			end
			while(op2_case != op2_case.first);
			op1_case = op1_case.next;
		end
		while(op1_case != op1_case.first);
		
		$display("Error To Test Ratio: %0d/%0d.", err_count,test_count);
	end
endmodule