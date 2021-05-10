/*
 * File: \align_sig.sv
 * Project: c:\Users\Chuck\ECE571\final_project\RISC-V-Floating-Point-Processor\src\design\chuck_test_code
 * Created Date: Thursday, May 6th 2021, 6:31:47 pm
 * Author: Chuck Faber
 * -----
 * Last Modified: Sun May 09 2021
 * Modified By: Chuck Faber
 * -----
 * Copyright (c) 2021 Portland State University
 * 
 * This module takes in two 23 bit significands and aligns them for addition later
 *
 * This module assumes that sig1 has the larger exponent and does not need shifting.
 * The swapping and complementing that may need to be done must be done by a prior module.
 *
 * The module will return a shifted and aligned sig2.
 * 
 * -----
 * HISTORY:
 * Date      	By	Comments
 * ----------	---	----------------------------------------------------------
 * 2021-05-06	CF	Added initial code. NOT YET TESTED.
 */


import addpkg::*;

module align_significands (
    sig2, shift, sig2_aligned
);

    input [22:0] sig2;
    input [7:0] shift;                      // Output of the subraction of the exponents
    output [22:0] sig2_aligned;             // Only outputting aligned op2, since op1 can just be passed through.

    sig2_aligned = sig2 >> shift;     // First shift brings hidden bit into significand

endmodule