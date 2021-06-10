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


parameter SIG_BITS = 23;
parameter EXP_BITS = 8;
module error_check (sign_i, exp_i, sig_untrunc_i, carry, nz_op, err_i, fp_out, err_o);

import fp_pkg::*;

parameter OVF_EXC = 0;

input sign_i;
input [EXP_BITS-1:0] exp_i;
input [SIG_BITS+3:0] sig_untrunc_i;
input carry;
input [EXP_BITS+SIG_BITS-1:0] nz_op;
input i_err_t err_i;
output logic [EXP_BITS+SIG_BITS:0] fp_out;
output o_err_t err_o;

logic sign_o;
logic [EXP_BITS-1:0] exp_o;
logic [SIG_BITS-1:0] sig_o;

always_comb begin
    sig_o = sig_untrunc_i[SIG_BITS+2:3];                                  // Truncate the hidden bit and round bits

    // Apply Logic Based on Err_i
    case (err_i)
        ZERO_OP_ERR: begin
            sign_o = sign_i;
            exp_o = nz_op[SIG_BITS+EXP_BITS-1:SIG_BITS];
            sig_o = nz_op[SIG_BITS-1:0];
        end
        INF_ERR: begin
            sign_o = sign_i;
            exp_o = {EXP_BITS{1'b1}};
            sig_o = {SIG_BITS{1'b0}};
        end
        NAN_ERR: begin
            sign_o = 1'b0;
            exp_o = {EXP_BITS{1'b1}};
            sig_o = {SIG_BITS{1'b1}};
        end
        ZERO_ERR: begin
            sign_o = 1'b0;
            exp_o = {EXP_BITS{1'b0}};
            sig_o = {SIG_BITS{1'b0}};
        end
        default: begin
            sign_o = sign_i;
            exp_o = exp_i;
        end
    endcase

    // Hacky way to address the Overflow Case Producing a NAN with all 1s in significand
    if (err_i != NAN_ERR && carry && exp_o == {EXP_BITS{1'b1}} && sig_o != 0) begin
        sig_o = {SIG_BITS{1'b0}};
    end

    // Do One last Check of Bits to Output the correct error
    if (exp_o == {EXP_BITS{1'b1}} && sig_o == 0) err_o = OVERFLOW;
    else if (exp_o == {EXP_BITS{1'b1}} && sig_o != 0) err_o = INVALID;
    else if (exp_o == {EXP_BITS{1'b0}} && sig_o != 0) err_o = UNDERFLOW;
    else err_o = NONE;


    // if (err_i == INF_ERR) begin                   // 3: Overflow Case (can happen as result or from inputs)
    //     err_o = OVERFLOW;
    //     sign_o = sign_i;
    //     exp_o = 8'hFF;
    //     sig = {23{1'b0}};
    // end else if (err_i == ZERO_OP_ERR) begin

    // end else if (err_i == NAN_ERR || (exp_i == 8'hFF && sig != 0)) begin     // 1: Invalid Case -- should only happen from inputs but check just in case
    //     err_o = INVALID;
    //     sign_o = 1'b0;
    //     exp_o = 8'hFF;
    //     sig = {23{1'b1}};
    // end else if (exp_i == 8'h00 && sig != 0) begin              // 4: Underflow Case (need to check result)
    //     err_o = UNDERFLOW;
    //     sign_o = sign_i;
    //     exp_o = exp_i;
    // end else if (err_i == ZERO_ERR) begin                           // Zero Case (not really an error but requires special handling)
    //     err_o = NONE;
    //     sign_o = 1'b0;
    //     exp_o = 8'b0;
    //     sig = {23{1'b0}};
    // end else begin                                              // 0: No Error Case
    //     err_o = NONE;
    //     sign_o = sign_i;
    //     exp_o = exp_i;
    // end
    fp_out = {sign_o, exp_o, sig_o};
end

endmodule