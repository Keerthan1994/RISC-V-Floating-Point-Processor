/*
 * File: \control.sv
 * Project: c:\Users\Chuck\ECE571\final_project\RISC-V-Floating-Point-Processor\src\design\chuck_test_code
 * Created Date: Thursday, May 6th 2021, 11:44:03 pm
 * Author: Bhargavi Chunchu
 * -----
 * Last Modified: Fri May 07 2021
 * Modified By: Bhargavi Chunchu
 * -----
 * Copyright (c) 2021 Portland State University
 * 
 * This module takes the input significand and outputs its two's complement value
 * 
 * 
 * -----
 * HISTORY:
 * Date      	By	Comments
 * ----------	---	----------------------------------------------------------
 */

module complement (
    input logic [22:0] significand, output logic [22:0] complemented_significand);
    logic [22:0] temp;
    assign temp = ~significand;
    assign complemented_significand = temp + 1;
endmodule