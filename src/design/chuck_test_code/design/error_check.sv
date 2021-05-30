// This is the final module which does an error check on the final result and truncates the significand
// Check to see if the exponent is all zeros (zero or denorm).
// Check to see if exponent is all 1's (NaN or infinity). Should also check carry outs of adds


module error_check (sign_i, exp_i, sig_untrunc_i, carry, nan, fp_out, error);

input sign_i;
input [7:0] exp_i;
input [26:0] sig_untrunc_i;
input carry;
input nan;
output [31:0] fp_out;
output [2:0] error;

logic [7:0] exp_o;
logic [22:0] sig;

always_comb begin

    if (nan) begin                          // Invalid Case
        error = 3'b001;
        exp_o = 8'hFF;
        sig = sig_untrunc_i[25:3];
        if (sig == 23'b0) sig = 23'b1;      // Significand needs to be non-zero to signify NaN result
    end else if (carry || (exp_i == 8'hFF)) begin


end

endmodule