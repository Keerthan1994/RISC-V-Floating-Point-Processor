/*
 * File: \add_sub_top.sv
 * Project: c:\Users\Chuck\ECE571\final_project\RISC-V-Floating-Point-Processor\src\design\chuck_test_code\design
 * Created Date: Thursday, May 27th 2021, 3:01:18 pm
 * Author: Chuck Faber
 * -----
 * Last Modified: Sun May 30 2021
 * Modified By: Chuck Faber
 * -----
 * Copyright (c) 2021 Portland State University
 * 
 * This module instantiates all of the F.P. add and subtract submodules needed
 * for this half of the FPU to work.
 * 
 * For a map of the sub-modules and their connections see: https://drive.google.com/file/d/1FjwbllU8rKIYsHBvdWdtsi0pOQ_f-xyd/view?usp=sharing
 * 
 * -----
 * HISTORY:
 * Date      	By	Comments
 * ----------	---	----------------------------------------------------------
 */


import addpkg::*; 
module add_sub_top(opcode, sign1, exp1, sig1, sign2, exp2, sig2, fp_out, err_o);

    // Ports
    input opcode;                       // 0: Add; 1: Subtract
    input logic [7:0] exp1, exp2;
    input logic [22:0] sig1, sig2;
    input logic sign1, sign2;
    output logic [31:0] fp_out;
    output logic [2:0] err_o;

    // Connection Wires
    i_err_t err_i;
    logic [7:0] exp1_d, exp2_d;
    logic [1:0] n_concat;
    logic [7:0] diff;
    logic [30:0] nz_op;
    logic borrow;
    logic swap;
    logic complement;

    logic [7:0] exp_r1, exp_r2;

    logic [22:0] sig1_s, sig2_s;
    logic [26:0] sig1_c, sig2_c;
    logic [26:0] sig1_cc, sig2_a;
    logic [26:0] sig_sum;
    logic [26:0] sig_pc;
    logic [26:0] sig_n;
    logic [26:0] sig_r;

    logic carry1, carry2, carry3, carry4, carry5;
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
        .complement(complement),
        .exp1(exp1), 
        .exp2(exp2), 
        .sig1(sig1), 
        .sig2(sig2), 
        .n_concat(n_concat), 
        .nz_op(nz_op),
        .exp1_d(exp1_d), 
        .exp2_d(exp2_d),
        .err(err_i)
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
        .n_concat(n_concat),
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
    align_significands as0 (
        .sig2(sig2_c), 
        .shift(shift1), 
        .sig2_aligned(sig2_a)
    );
    nbit_fulladder #(27) fa0 (
        .S(sig_sum), 
        .CO(carry1), 
        .A(sig1_cc), 
        .B(sig2_a), 
        .CI(1'b0)
    );                              // Adds sig1_cc and sig2_a
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
    nbit_fulladder #(8) fa1 (
        .S(exp_r2), 
        .CO(carry4), 
        .A(exp_r1), 
        .B(shift2), 
        .CI(1'b0)
    );                              // Adds exp_r1 and shift2
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
    nbit_fulladder #(8) fa2 (
        .S(exp_f), 
        .CO(carry5), 
        .A(exp_r2), 
        .B(shift3), 
        .CI(carry4)
    );                              // Adds exp_r2 and shift3
    error_check ec0 (
        .sign_i(sign_r), 
        .exp_i(exp_f), 
        .sig_untrunc_i(sig_f),
        .carry(carry2),
        .nz_op(nz_op),
        .err_i(err_i), 
        .fp_out(fp_out), 
        .err_o(err_o)
    );


endmodule