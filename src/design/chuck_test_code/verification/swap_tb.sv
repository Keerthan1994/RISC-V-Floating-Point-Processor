// cfaber - 5/16 Module Verified

module top ();

import addpkg::*;


shortreal op1[] = '{1.0, 0.25, 0.05, 0, 20.1};
shortreal op2[] = '{0.05, 1.23, 5.1, 0.001, 0.023};
fp_t fp1, fp2;
logic [22:0] sig1, sig2, sig1_o, sig2_o;
logic [7:0] exp1, exp2, exp_r, diff, shift;
logic borrow, swap;

compare_exponents ce0 (
    .exp1(exp1), 
    .exp2(exp2), 
    .diff(diff), 
    .exp_r(exp_r),
    .borrow(borrow)
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
    foreach (op1[i]) begin
        fp1 = fpUnpack(op1[i]);
        fp2 = fpUnpack(op2[i]);
        exp1 = fp1.unpkg.exponent;
        exp2 = fp2.unpkg.exponent;
        sig1 = fp1.unpkg.significand;
        sig2 = fp2.unpkg.significand;
        #10
        $display("op1: %10f op2: %10f; exp1: %3d exp2: %3d, borrow: %1b, swap?: %1b, diff: %8d, shift: %8d", op1[i], op2[i], exp1, exp2, borrow, swap, diff, shift);
    end
end

endmodule