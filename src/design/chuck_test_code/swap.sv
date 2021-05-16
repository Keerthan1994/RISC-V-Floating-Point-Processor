/*
 * File: \swap.sv
 * Project: c:\Users\Chuck\ECE571\final_project\RISC-V-Floating-Point-Processor\src\design\chuck_test_code
 * Created Date: Sunday, May 9th 2021, 10:05:45 pm
 * Author: Chuck Faber
 * -----
 * Last Modified: Sun May 16 2021
 * Modified By: Chuck Faber
 * -----
 * Copyright (c) 2021 Portland State University
 * 
 * If borrow is true swap the operands and set swap signal.
 * Also if borrow is true, complement diff to send out as shift.
 * 
 * 
 * -----
 * HISTORY:
 * Date      	By	Comments
 * ----------	---	----------------------------------------------------------
 */

module swap (
    sig1, sig2, diff, borrow, shift, swap, sig1_swap, sig2_swap
);

input [22:0] sig1, sig2;
input [7:0] diff;
input borrow;
output [7:0] shift;
output swap;
output [22:0] sig1_swap, sig2_swap;

always_comb begin
    if (borrow) begin                                   // Difference is negative, swap operands
        sig1_swap = sig2;
        sig2_swap = sig1;
        shift = ~diff + 1;
        swap = 1'b1;
    end else if (diff == 0 && (sig2 > sig1)) begin        // difference is zero and sig2 is larger than sig1, swap operands
        sig1_swap = sig2;
        sig2_swap = sig1;
        shift = diff;
        swap = 1'b1;
    end else begin                                      // Difference is positive so sig1 > sig2
        sig1_swap = sig1;
        sig2_swap = sig2;
        shift = diff;
        swap = 1'b0'
    end
end

endmodule