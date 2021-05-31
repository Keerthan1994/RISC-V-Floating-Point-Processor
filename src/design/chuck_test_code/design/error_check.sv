/*
 * File: \error_check.sv
 * Project: c:\Users\Chuck\ECE571\final_project\RISC-V-Floating-Point-Processor\src\design\chuck_test_code\design
 * Created Date: Sunday, May 30th 2021, 12:27:28 pm
 * Author: Chuck Faber
 * -----
 * Last Modified: Sun May 30 2021
 * Modified By: Chuck Faber
 * -----
 * Copyright (c) 2021 Portland State University
 * 
 * This is the final module which does an error check on the final result and produces the correct error code
 * if one is needed. The error codes are as follows:
 * 0 - No Error
 * 1 - Invalid: NaN Operation. Produces a NaN where exponent is all 1s and the sig is nonzero.
 * 2 - Divide by Zero: Not applicable to Add/Sub.
 * 3 - Overflow: results in infinity. Exponent is all 1s and the sig is all 0s.
 * 4 - Underflow: result is a denormal number.
 * 5 - Inexact: the result has been rounded at some point. (We will not implement this one atm since it's not very useful)
 * 
 * This module also packages the result for final output by truncating the hidden bit, and the 3 rounding bits.
 * 
 * -----
 * HISTORY:
 * Date      	By	Comments
 * ----------	---	----------------------------------------------------------
 */


module error_check (sign_i, exp_i, sig_untrunc_i, carry, nan, fp_out, error);

input sign_i;
input [7:0] exp_i;
input [26:0] sig_untrunc_i;
input carry;
input nan;
output logic [31:0] fp_out;
output logic [2:0] error;

logic [7:0] exp_o;
logic [22:0] sig;

always_comb begin
    sig = sig_untrunc_i[25:3];                          // Truncate the hidden bit and round bits

    if (nan) begin                                      // 1: Invalid Case
        error = 3'd1;
        exp_o = 8'hFF;
        sig = {23{1'b1}};
    end else if (carry || (exp_i == 8'hFF)) begin       // 3: Overflow Case
        error = 3'd3;
        exp_o = 8'hFF;
        sig = {23{1'b0}};
    end else if (exp_i == 8'h00 && sig != 0) begin      // 4: Underflow Case
        error = 3'd4;
        exp_o = exp_i;
    end else begin                                      // 0: No Error Case
        exp_o = exp_i;
        error = 3'd0;
    end
    fp_out = {sign_i, exp_o, sig};
end

endmodule