/*
 * File: \align_sig.sv
 * Project: c:\Users\Chuck\ECE571\final_project\RISC-V-Floating-Point-Processor\src\design\chuck_test_code
 * Created Date: Thursday, May 6th 2021, 6:31:47 pm
 * Author: Chuck Faber
 * -----
 * Last Modified: Thu May 06 2021
 * Modified By: Chuck Faber
 * -----
 * Copyright (c) 2021 Portland State University
 * 
 * This module takes in two single precision IEEE-754 floating point operands
 * and aligns the signficands and adjusts the exponent so that it can be added later.
 *
 * This module assumes that op1 has the larger exponent and does not need shifting.
 * The swapping and complementing that may need to be done must be done by a prior module.
 *
 * The module will return a shifted and aligned op2 for adding in a separate module.
 * 1
 * -----
 * HISTORY:
 * Date      	By	Comments
 * ----------	---	----------------------------------------------------------
 * 2021-05-06	CF	Added initial code. NOT YET TESTED.
 */


import addpkg::*;

module align_significands (
    op1, op2, op2_aligned
);

    input fp_t op1, op2;
    output fp_t op2_aligned;            // Only outputting aligned op2, since op1 can just be passed through.

    unsigned int SHIFT = op1.unpkg.exponent - op2.unpkg.exponent;

    if (SHIFT != 0) begin
        op2_aligned.unpkg.sign = op2.unpkg.sign;
        op2_aligned.unpkg.exponent = op1.unpkg.exponent;
        op2_aligned.unpkg.significand = {1'b1, op2.unpkg.significand} >> (SHIFT-1);     // First shift brings hidden bit into significand
    end else begin
        op2_aligned = op2;
    end

endmodule