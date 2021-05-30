import fp::*;

module add_top(op1, op2, opcode, out, error);

    input fp_t op1, op2;
    input opcode;
    output fp_t bin_out;
    output error;

    // Unpacked Fields
    logic [7:0] exp1, exp2;
    logic [22:0] sig1, sig2;
    logic sign1, sign2;

    // Connection Wires
    logic [7:0] exp1_d, exp2_d;
    logic [1:0] n_concat;
    logic [7:0] diff;
    logic borrow;
    logic swap;
    logic complement;

    logic [7:0] exp_r1, exp_r2;

    logic [22:0] sig1_s, sig2_s;
    logic [26:0] sig1_c, sig2_c;
    logic [26:0] sig1_cc, sig2_a;
    logic [26:0] sig_sum;
    logic [26:0] sig_pc;
    logic [26:0] sig_r;

    logic carry1, carry2, carry3;
    logic[7:0] shift1, shift2, shift3;

    logic sign_r;
    logic [7:0] exp_f;
    logic [26:0] sig_f;


    // Unpack Here
    sign_logic sl0 (
        .sign1(sign1),
        .sign2(sign2),
        .opcode(opcode),
        .swap(swap),
        .complement(complement),
        .sign_r(sign_r)
    );
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
        .exp_r(exp_r1), 
        .borrow(borrow)
    );
    swap sw0 (
        .sig1(sig1), 
        .sig2(sig2), 
        .diff(diff), 
        .borrow(borrow), 
        .shift(shift1), 
        .swap(swap), 
        .sig1_swap(sig1_s), 
        .sig2_swap(sig2_s)
    );
    concat_1 cc0 (
        .sig1(sig1_s), 
        .sig2(sig2_s), 
        .n_concat(n_concat), 
        .swap(swap), 
        .sig1_concat(sig1_c), 
        .sig2_concat(sig2_c)
    );
    complement comp0 (
        .complement(complement), 
        .operand(sig1_c), 
        .op_comp(sig1_cc)
    );
    align_significands (
        .sig2(sig2_c), 
        .shift(shift1), 
        .sig2_aligned(sig2_a)
    );
    fulladdr fa0 (
        .S(sig_sum), 
        .CO(carry1), 
        .A(sig1_cc), 
        .B(sig2_a), 
        .CI(1'b0)
    );            // Adds sig1_cc and sig2_a
    postcomplement pc0 (
        .complement(complement), 
        .co_i(carry1), 
        .operand(sig_sum), 
        .op_comp(sig_pc), 
        .co_o(carry2)
    );
    normalize nm0 (
        .sig(sig_pc), 
        .carry(carry2), 
        .exp(exp_r1), 
        .sig_norm(sig_n), 
        .shift(shift2)
    );
    fulladdr fa1 (
        .S(exp_r2), 
        .CO(carry4), 
        .A(exp_r1), 
        .B(shift2), 
        .CI(1'b0)
    );            // Adds exp_r1 and shift2
    rounding rd0 (
        .sig_n(sig_n), 
        .sig_r(sig_r), 
        .co(carry3)
    );
    normalize nm1 (
        .sig(sig_r), 
        .carry(carry3), 
        .exp(exp_r2), 
        .sig_norm(sig_f), 
        .shift(shift3)
    );
    fulladdr fa2 (
        .S(exp_f), 
        .CO(carry5), 
        .A(exp_r2), 
        .B(shift3), 
        .CI(carry4)     // FIXME: Debatable whether to do this.
    );            // Adds exp_r2 and shift3
    error_check ec0 ();


endmodule