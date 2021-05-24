import fp::*;

module add_top(input fp_t bin_val1, bin_val2, input opcode, output fp_t bin_out, output error);

    logic [7:0] exp1, exp2;
    logic [22:0] sig1, sig2;
    logic sign1, sign2;
    logic [7:0] exp1_d, exp2_d;
    logic [1:0] n_concat;
    logic [7:0] diff;
    logic borrow;
    logic[7:0] shift, shift_norm;
    logic swap;
    logic [22:0] sig1_swap, sig2_swap;
    logic complement;
    logic sign_r;
    logic [26:0] sig1_concat, sig2_concat, sig1_compl, sig2_aligned, sig_pc;
    logic co;
    logic [26:0] sum;

    denorm_zero denz(exp1, exp2, sig1, sig2, n_concat, exp1_d, exp2_d);
    compare_exponents comp(exp1, exp2, diff, exp_r, borrow);
    swap sw(sig1, sig2, diff, borrow, shift, swap, sig1_swap, sig2_swap);
    sign_logic si(sign1, sign2, opcode, swap, complement, sign_r);
    concat_1 cat(sig1_swap, sig2_swap, n_concat, swap, sig1_concat, sig2_concat);
    complement cot(complement, sig1_concat, sig1_compl);
    align_significands ali(sig2_concat, shift, sig2_aligned);
    add_significands add(sig1_cc, sig2_a, co, sum);
    complement cot2(co, sum, sig_pc);
    normalize norm(sig_pc, co, exp_r, sig_norm, shift_norm); 
        

endmodule