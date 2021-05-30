// This is the final module which does an error check on the final result and truncates the significand
// Check to see if the exponent is all zeros (zero or denorm).
// Check to see if exponent is all 1's (NaN or infinity). Should also check carry outs of adds

module error_check (sign_i, exp_i, sig_untrunc_i, sign_o, exp_o, sig_o, error);

input sign_1;
input [7:0] exp_i;
input [26:0] sig_untrunc_i;
output sign_o;
output [7:0] exp_o;
output [22:0] sig_o;
output error;

always_comb begin
end

endmodule