/*
 * File: \control.sv
 * Project: c:\Users\Chuck\ECE571\final_project\RISC-V-Floating-Point-Processor\src\design\chuck_test_code
 * Created Date: Thursday, May 6th 2021, 11:44:03 pm
 * Author: Chuck Faber
 * -----
 * Last Modified: Sun May 09 2021
 * Modified By: Chuck Faber
 * -----
 * Copyright (c) 2021 Portland State University
 * 
 * This module takes in an input to determine whether the floating point
 * operation is an addition or subtraction. It adjusts the sign bit accordingly.
 * 
 * The document mentions that this also should determine which operand should be
 * preshifted? The diagram doesn't show this.
 * 
 * Also when adding operands of unlike signs, the operand that isn't preshifted
 * is complemented? The prior two sentences sounds like part of the compare_exponents
 * and the swap_and_complement modules...
 *
 * This whole module needs some more defining of how it works and what it does.
 * 
 * 
 * -----
 * HISTORY:
 * Date      	By	Comments
 * ----------	---	----------------------------------------------------------
 */

module sign_logic (
    sign1, sign2, opcode, swap, complement, sign_r
);
    input sign1, sign2;             // Sign bit from each operand
    input opcode;                   // Opcode defining addition or subtraction
    input swap;                     // Swap signal, if true, Op2 is greater than Op1.
    output complement;              // Complement signal means we pre-complement and post complement
    output sign_r;                  // resultant sign bit


endmodule