/*
 * File: \normalize.sv
 * Project: c:\Users\Chuck\ECE571\final_project\RISC-V-Floating-Point-Processor\src\design\chuck_test_code
 * Created Date: Thursday, May 6th 2021, 11:36:37 pm
 * Author: Chuck Faber
 * -----
 * Last Modified: Sun May 09 2021
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
 * -----
 * HISTORY:
 * Date      	By	Comments
 * ----------	---	----------------------------------------------------------
 */

module normalize (
    sig, sig_norm, shift
);

input [22:0] sig;
output logic [22:0] sig_norm;
output logic [7:0] shift;


endmodule