/*
 * File: \complement.sv
 * Project: c:\Users\Chuck\ECE571\final_project\RISC-V-Floating-Point-Processor\src\design\chuck_test_code
 * Created Date: Sunday, May 9th 2021, 9:59:33 pm
 * Author: Chuck Faber
 * -----
 * Last Modified: Fri May 14 2021
 * Modified By: Chuck Faber
 * -----
 * Copyright (c) 2021 Portland State University
 * 
 * If the complement signal is given the value is 2's complemented
 * 
 * 
 * 
 * -----
 * HISTORY:
 * Date      	By	Comments
 * ----------	---	----------------------------------------------------------
 */

module complement (
    complement, operand, op_comp
);

input complement;
input [26:0] operand;
output logic [26:0] op_comp;

always_comb begin
    op_comp = complement ? ~operand + 1 : operand;
end

endmodule