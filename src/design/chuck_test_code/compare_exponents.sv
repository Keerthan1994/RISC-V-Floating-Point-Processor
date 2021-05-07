/*
 * File: \compare_exponents.sv
 * Project: c:\Users\Chuck\ECE571\final_project\RISC-V-Floating-Point-Processor\src\design\chuck_test_code
 * Created Date: Thursday, May 6th 2021, 7:11:34 pm
 * Author: Chuck Faber
 * -----
 * Last Modified: Thu May 06 2021
 * Modified By: Chuck Faber
 * -----
 * Copyright (c) 2021 Portland State University
 * 
 * This modules takes in two 8-bit single precision floating point exponent values,
 * and outputs the difference between them and the larger of the two exponents.
 * 
 * 
 * -----
 * HISTORY:
 * Date      	By	Comments
 * ----------	---	----------------------------------------------------------
 */

module compare_exponents(
    exp1, exp2, diff, exp_r
);
    input [7:0] exp1, exp2;
    output [7:0] diff, exp_r;

    // This module needs to subtract the two exponents (exp1 - exp2), and then 
    // depending on if the value is positive or negative output exp1 or exp2
    // and the absolute difference between the two exponents.
    // Diagram uses a full subtractor, dunno if this is what I wanna do.

endmodule