/*
 * File: \swap.sv
 * Project: c:\Users\Chuck\ECE571\final_project\RISC-V-Floating-Point-Processor\src\design\chuck_test_code
 * Created Date: Sunday, May 9th 2021, 10:05:45 pm
 * Author: Chuck Faber
 * -----
 * Last Modified: Wed May 12 2021
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
    op1, op2, diff, borrow, shift, swap, op1_swap, op2_swap
);

input [22:0] op1, op2;
input [7:0] diff;
input borrow;
output [7:0] shift;
output swap;
output [22:0] op1_swap, op2_swap;


if (borrow) begin                                   // Difference is negative, swap operands
    op1_swap = op2;
    op2_swap = op1;
    shift = ~diff + 1;
    swap = 1'b1;
end else if (diff == 0 && (op2 > op1)) begin        // difference is zero and op2 is larger than op1, swap operands
    op1_swap = op2;
    op2_swap = op1;
    shift = diff;
    swap = 1'b1;
end else begin                                      // Difference is positive so op1 > op2
    op1_swap = op1;
    op2_swap = op2;
    shift = diff;
    swap = 1'b0'
end

endmodule