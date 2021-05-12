module denorm_zero (exp1, exp2, sig1, sig2, n_concat, exp1_d, exp2_d);

input [7:0] exp1, exp2;
input [22:0] sig1, sig2;
output [7:0] exp1_d, exp2_d;
output [1:0] n_concat;

// If exoponent is zero, and sig is nonzero, set exponent to 1
if (exp1 == 8'b0) begin
    n_concat[1] = 1'b1;         // Don't add leading 1 to op1
    if (sig1 != 23'b0) begin    // Op1 is subnormal number
        exp1_d = 8'b1;          // Make exponent equal to 1 (-126)
    end else begin              // Op1 is zero
        exp1_d = exp1;          // Keep exponent as zero
    end
end else begin                  // Number is neither zero nor subnormal
    n_concat[1] = 1'b0;
    exp1_d = exp1;
end

if (exp2 == 8'b0) begin
    n_concat[0] = 1'b1;         // Don't add leading 1 to op2
    if (sig2 != 23'b0) begin    // Op2 is subnormal number
        exp2_d = 8'b1;          // Make exponent equal to 1 (-126)
    end else begin              // Op2 is zero
        exp2_d = exp2;          // Keep exponent as zero
    end
end else begin                  // Number is neither zero nor subnormal
    n_concat[0] = 1'b0;
    exp2_d = exp2;
end

endmodule