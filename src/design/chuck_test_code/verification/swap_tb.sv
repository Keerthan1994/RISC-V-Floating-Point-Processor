import addpkg::*;

module top ();

shortreal op1, op2;
fp_t fp1, fp2;
logic [22:0] sig1, sig2, sig1_o, sig2_o;
logic [7:0] exp1, exp2, exp_r, diff, shift;
logic borrow, swap;

op1 = '{1.0, 0.25, 0.05, 0, 20.1};
op2 = '{0.05, 1.23, 5.1, 0.001, 0.023};

compare_exponents ce0 (
    .exp1(exp1), 
    .exp2(exp2), 
    .diff(diff), 
    .exp_r(exp_r)
);

swap swp0 (
    .sig1(sig1), 
    .sig2(sig2), 
    .diff(diff), 
    .borrow(borrow), 
    .shift(shift), 
    .swap(swap), 
    .sig1_swap(sig1_o), 
    .sig2_swap(sig2_o)
);

initial begin
    foreach(op1[i]) begin
        fp1 = fpUnpack(op1[i]);
        fp2 = fpUnpack(op2[i]);
        exp1 = fp1.unpkg.exponent;
        exp2 = fp2.unpkg.exponent;
        sig1 = fp1.unpkg.significand;
        sig2 = fp2.unpkg.significand;
    end
end

endmodule