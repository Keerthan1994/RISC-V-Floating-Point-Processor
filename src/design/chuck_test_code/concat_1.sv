/*
 * File: \concat_1.sv
 * Project: c:\Users\Chuck\ECE571\final_project\RISC-V-Floating-Point-Processor\src\design\chuck_test_code
 * Created Date: Sunday, May 9th 2021, 9:55:12 pm
 * Author: Chuck Faber
 * -----
 * Last Modified: Wed May 12 2021
 * Modified By: Chuck Faber
 * -----
 * Copyright (c) 2021 Portland State University
 * 
 * Concatenates the hidden 1 bit at the beginning of the significand.
 * 
 * 
 * 
 * -----
 * HISTORY:
 * Date      	By	Comments
 * ----------	---	----------------------------------------------------------
 */

module concat_1 (
    operand1, operand2, n_concat, swap, op1_concat, op2_concat
);

input [22:0] logic operand1, operand2;
input [1:0] logic n_concat;
input swap;
output [23:0] logic op1_concat, op2_concat;

// If operands were swapped, also swap concat bits.
n_concat[1:0] = swap ? {n_concat[0], n_concat[1]} : n_concat[1:0];

// If no-concat signal true (for zero or denorm numbers) append 0, else append 1. 
op1_concat = {~n_concat[1], operand1};
op2_concat = {~n_concat[0], operand2};

endmodule