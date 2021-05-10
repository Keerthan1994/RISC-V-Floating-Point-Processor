/*
 * File: \concat_1.sv
 * Project: c:\Users\Chuck\ECE571\final_project\RISC-V-Floating-Point-Processor\src\design\chuck_test_code
 * Created Date: Sunday, May 9th 2021, 9:55:12 pm
 * Author: Chuck Faber
 * -----
 * Last Modified: Sun May 09 2021
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
    operand1, operand2, op1_concat, op2_concat
);

input [22:0] logic operand1, operand2;
output [23:0] logic op1_concat, op2_concat;

op1_concat = {1'b1, operand1};
op2_concat = {1'b1, operand2};

endmodule