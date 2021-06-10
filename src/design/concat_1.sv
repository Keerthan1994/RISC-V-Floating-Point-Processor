/*
 * File: \concat_1.sv
 * Project: c:\Users\Chuck\ECE571\final_project\RISC-V-Floating-Point-Processor\src\design\chuck_test_code
 * Created Date: Sunday, May 9th 2021, 9:55:12 pm
 * Author: Chuck Faber
 * -----
 * Last Modified: Fri May 14 2021
 * Modified By: Chuck Faber
 * -----
 * Copyright (c) 2021 Portland State University
 * 
 * Concatenates the hidden 1 bit at the beginning of the significand.
 * Also concatenates 3 zeroes at the end for rounding, sticky, and guard bits.
 * 
 * 
 * -----
 * HISTORY:
 * Date      	By	Comments
 * ----------	---	----------------------------------------------------------
 */

parameter SIG_BITS = 23;
parameter EXP_BITS = 8;
module concat_1 (
    sig1, sig2, n_concat, swap, sig1_concat, sig2_concat
);

input logic [SIG_BITS-1:0] sig1, sig2;
input logic [1:0] n_concat;
input swap;
output logic [SIG_BITS+3:0] sig1_concat, sig2_concat;
logic [1:0] n_concat_s;

always_comb begin
    // If operands were swapped, also swap concat bits.
    n_concat_s[1:0] = swap ? {n_concat[0], n_concat[1]} : n_concat[1:0];

    // If no-concat signal true (for zero or denorm numbers) append 0, else append 1.
    // Also append 3 0s for rounding
    sig1_concat = {~n_concat_s[1], sig1, 3'b000};
    sig2_concat = {~n_concat_s[0], sig2, 3'b000};
end

endmodule