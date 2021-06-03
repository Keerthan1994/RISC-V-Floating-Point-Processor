/*
 * File: \denorm_zero.sv
 * Project: c:\Users\Chuck\ECE571\final_project\RISC-V-Floating-Point-Processor\src\design\chuck_test_code\design
 * Created Date: Thursday, May 27th 2021, 3:01:18 pm
 * Author: Chuck Faber
 * -----
 * Last Modified: Sun May 30 2021
 * Modified By: Chuck Faber
 * -----
 * Copyright (c) 2021 Portland State University
 * 
 * This module checks to see if either operand is a NaN in which case it outputs a signal to the final stage
 * informing it that the result should also be NaN and send the correct error code.
 * 
 * This module also checks to see if either of the operands is denormal, in which case it will tell the unit
 * to not concatenate the hidden 1 the value at the concat stage.
 * 
 * -----
 * HISTORY:
 * Date      	By	Comments
 * ----------	---	----------------------------------------------------------
 */

// FIXME: Should also probably check if EXP represents Infinity or NaN (NaN done).
// http://pages.cs.wisc.edu/~markhill/cs354/Fall2008/notes/flpt.apprec.html
// If so, send a signal to final stage, and inform it to ouput NaN.
// FIXME: Should also check if the operands equal one another AND the complement signal
// is true. If so, we need to output a zero signal in the final stage.


module denorm_zero (complement, exp1, exp2, sig1, sig2, n_concat, exp1_d, exp2_d, err);

import addpkg::*;

input complement;
input [7:0] exp1, exp2;
input [22:0] sig1, sig2;
output logic [7:0] exp1_d, exp2_d;
output logic [1:0] n_concat;
output i_err_t err;
    // 0: Not Special
    // 1: Zero
    // 2: NaN
    // 3: Inf

//output logic nan;

i_err_t op1_err, op2_err;

always_comb begin
    // SPECIAL CASES
    // Operand 1 Special Case
    if (exp1 == 8'hFF && sig1 == 23'b0) op1_err = INF_ERR;
    else if (exp1 == 8'hFF && sig1 != 23'b0) op1_err = NAN_ERR;
    else op1_err = NO_ERR;

    // Operand 2 Special Case
    if (exp2 == 8'hFF && sig2 == 23'b0) op2_err = INF_ERR;
    else if (exp2 == 8'hFF && sig2 != 23'b0) op2_err = NAN_ERR;
    else op2_err = NO_ERR;

    // SPECIAL CASES LOGIC:
    // One of the inputs is a NaN -- Output should be NaN
    if (op1_err == NAN_ERR || op2_err == NAN_ERR) err = NAN_ERR;
    // One of the inputs is INF, but the other is NOT INF -- Output should be INF
    else if (op1_err == INF_ERR && op2_err == NO_ERR || op1_err == NO_ERR && op2_err == INF_ERR) err = INF_ERR;
    // Both inputs are INF, but the complement signal is false -- Output should be INF
    else if (op1_err == INF_ERR && op2_err == INF_ERR && !complement) err = INF_ERR;
    // Both inputs are INF, but the complement signal is true -- Output should be NaN
    else if (op1_err == INF_ERR && op2_err == INF_ERR && complement) err = NAN_ERR;
    // Both inputs are equal, and the complement signal is true -- Output should be ZERO.
    else if (exp1 == exp2 && sig1 == sig2 && complement) err = ZERO_ERR;
    // Otherwise no special error case.
    else err = NO_ERR;

    // DENORM INPUTS PROCESSING
    // If exponent is zero, and sig is nonzero, set exponent to 1

    // Exponent 1 Denorm Processing
    if (exp1 == 8'b0) begin
        n_concat[1] = 1'b1;         // Don't add leading 1 to op1
        if (sig1 != 23'b0) begin    // Op1 is subnormal number
            exp1_d = 8'b1;          // Make exponent equal to 1 (-126)
        end else begin              // Op1 is zero
            exp1_d = exp1;          // Keep exponent as zero
        end
    end else begin                  // Number is neither zero nor subnormal
        n_concat[1] = 1'b0;
        exp1_d = exp1;
    end

    // Exponent 2 Denorm Processing
    if (exp2 == 8'b0) begin
        n_concat[0] = 1'b1;         // Don't add leading 1 to op2
        if (sig2 != 23'b0) begin    // Op2 is subnormal number
            exp2_d = 8'b1;          // Make exponent equal to 1 (-126)
        end else begin              // Op2 is zero
            exp2_d = exp2;          // Keep exponent as zero
        end
    end else begin                  // Number is neither zero nor subnormal
        n_concat[0] = 1'b0;
        exp2_d = exp2;
    end

end

endmodule