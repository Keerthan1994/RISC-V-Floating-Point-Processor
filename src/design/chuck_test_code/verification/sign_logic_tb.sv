import addpkg::*;

module top();

shortreal op1[] = '{1.0, 0.25, 0.05, 0, 20.1};
shortreal op2[] = '{0.05, 1.23, 5.1, 0.001, 0.023};
fp_t fp1, fp2;

logic [7:0] exp1, exp2;
logic [22:0] sig1, sig2;
logic [7:0] exp1_d, exp2_d;
logic [1:0] n_concat;

logic [22:0] sig1_swap, sig2_swap;
logic [7:0] exp_r, diff, shift;
logic borrow, swap;

logic sign1, sign2;             // Sign bit from each operand
logic opcode;                   // Opcode defining addition (0) or subtraction (1)
logic complement;              // Complement signal means we pre-complement and post complement
logic sign_r;                  // resultant sign bit



denorm_zero dz0 (
    .exp1(exp1), 
    .exp2(exp2), 
    .sig1(sig1), 
    .sig2(sig2), 
    .n_concat(n_concat), 
    .exp1_d(exp1_d), 
    .exp2_d(exp2_d)
    );

compare_exponents ce0 (
    .exp1(exp1_d), 
    .exp2(exp2_d), 
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
    .sig1_swap(sig1_swap), 
    .sig2_swap(sig2_swap)
);

sign_logic sl0 (
    .sign1(sign1), 
    .sign2(sign2), 
    .opcode(opcode), 
    .swap(swap), 
    .complement(complement), 
    .sign_r(sign_r)
);

initial begin
    foreach (op1[i]) begin
        fp1 = fpUnpack(op1[i]);
        fp2 = fpUnpack(op2[i]);
        sign1 = fp1.unpkg.sign;
        sign2 = fp2.unpkg.sign;
        exp1 = fp1.unpkg.exponent;
        exp2 = fp2.unpkg.exponent;
        sig1 = fp1.unpkg.significand;
        sig2 = fp2.unpkg.significand;
        opcode = (i%2 == 0) ? 1'b0 : 1'b1;
        #10
        $display("op1: %10f op2: %10f; operation: %s; swap: %1b; Resulting Sign: %s", op1[i], op2[i], opcode ? "sub" : "add", swap, sign_r ? "-" : "+");
    end
end

endmodule