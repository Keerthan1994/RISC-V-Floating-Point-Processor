/*
 * File: \align_sig.sv
 * Project: c:\Users\Chuck\ECE571\final_project\RISC-V-Floating-Point-Processor\src\design\chuck_test_code
 * Created Date: Thursday, May 6th 2021, 6:31:47 pm
 * Author: Chuck Faber
 * -----
 * Last Modified: Fri May 14 2021
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

input [26:0] sig2;
input [7:0] shift;                      // Output of the subraction of the exponents
output [26:0] sig2_aligned;             // Only outputting aligned op2, since op1 can just be passed through.
logic sticky;


always_comb begin

    // if (shift > 0) begin
    //     shifted_out = sig2[(shift-1)+3:3];

    //     sig2[GUARD] = shifted_out[shift-1];
    //     sig2[ROUND] = shifted_out[shift-2];
    //     sig2[STICKY] = |shifted_out[shift-3:0];
    // end

    if (shift > 3) begin
        sticky = |sig2[shift-3:0];
    end

    // sig_tmp = sig2[26:3];
    // if (shift > 0) begin
    //     sig2[GUARD] = sig_tmp[0];
    // end
    // if (shift > 1) begin
    //     sig2[ROUND] = sig_tmp[1];
    // end
    // if (shift > 2) begin
    //     // check if any bit between sig_tmp[shift:2] is 1
    //     sig2[STICKY] = |sig_tmp[shift:2];
    // end

    sig2_aligned = sig2 >> shift;     // First shift brings hidden bit into significand (combinational)
    if (shift > 3) begin
        sig2_aligned[0] = sticky;
    end
end

endmodule