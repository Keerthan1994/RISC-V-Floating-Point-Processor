/*
 * File: \normalize.sv
 * Project: c:\Users\Chuck\ECE571\final_project\RISC-V-Floating-Point-Processor\src\design\chuck_test_code
 * Created Date: Thursday, May 6th 2021, 11:36:37 pm
 * Author: Chuck Faber
 * -----
 * Last Modified: Fri May 14 2021
 * Modified By: Chuck Faber
 * -----
 * Copyright (c) 2021 Portland State University
 * 
 * Takes in the summed significands, and carry out from the ALU checks 
 * if normalization is necessary and performs the normalization shift necessary.
 * 
 * Outputs the normalized signficand, and the shift value (negative for
 * left shift, positive for right shift) which will be added to the exponent.
 * 
 * May need to adjust logic/ports for the rounding module.
 * 
 * -----
 * HISTORY:
 * Date      	By	Comments
 * ----------	---	----------------------------------------------------------
 */

module normalize (
    sig, carry, exp, sig_norm, shift
);

input [26:0] sig;
input carry;
input [7:0] exp;
output logic [26:0] sig_norm;
output logic [7:0] shift;



logic [4:0] first_one;
logic [7:0]  norm_shift;

find_first_1 #(27) ff1 (sig, first_one);

always_comb begin
    if (carry) begin                     // If there is a carry we need to shift just 1 to the right, and increment the exponent.
        sig_norm = sig >> 1;
        sig_norm[26] = carry;
        shift = 1;
    end else if (sig == 0) begin            // The entire significand is 0, so the value is zero (that's only the case if using denorm numbers or zero math)
        sig_norm = sig;
        // Need to do a check if the exponent is 1 or 0. If it is 1, set it to zero. Otherwise it is already zero, so leave it at that.
        if (exp == 8'b1) begin
            shift = -1;
        end else begin
            shift = 0;
        end
    end else if (sig != 0 && exp == 8'b1 && sig[26] != 1'b1) begin    // If the sig is not zero, no carry out, and no MSB and the exponent is 1, output a denorm number.
        sig_norm = sig;
        shift = -1;                         // Change the exponent to 0
    end else begin                          // Else keep shifting to the left and decrementing exponent until there is a 1 in the MSB.
        norm_shift = 26 - first_one;
        sig_norm = sig << norm_shift;
        shift = -norm_shift;
    end
end

endmodule