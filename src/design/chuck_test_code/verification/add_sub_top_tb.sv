import addpkg::*;

module top();

// shortreal op1, op2, out;
shortreal out_sr;
fp_t op1, op2, out;

logic sign1, sign2;
logic [7:0] exp1, exp2;
logic [22:0] sig1, sig2;
logic opcode;
logic [31:0] fp_out;
logic [2:0] error;

add_sub_top ast0 (.*);

// 0 01111111 10011001100110011001101   1.6
// Add 1 to exp or complement. 2s complement sig.

// 0 01111110 10011001100110011001101   0.8
// 0 10000000 01100110011001100110011   2.8


initial begin
    $monitor("swap: %01b complement: %01b exp_r1: %08b shift1: %08d shift2: %08d exp_r2: %08b shift3: %08d carry1: %1b carry2: %1b carry3: %1b carry4: %1b \nsig1_c: %027b sig2_c: %027b sig1_cc: %027b sig2_a: %027b sig_sum: %027b \nsig_pc: %027b sig_r: %27b \nresult: %1b %8b %027b\n", ast0.swap, ast0.complement, ast0.exp_r1, ast0.shift1, ast0.shift2, ast0.exp_r2, ast0.shift3, ast0.carry1, ast0.carry2, ast0.carry3, ast0.carry4, ast0.sig1_c, ast0.sig2_c, ast0.sig1_cc, ast0.sig2_a, ast0.sig_sum, ast0.sig_pc, ast0.sig_r, ast0.sign_r, ast0.exp_f, ast0.sig_f);
    // $monitor("Complement: %1b.", ast0.complement);

    #10;
    op1 = fpUnpack(0.3);
    op2 = fpUnpack(2.5);
    sign1 = op1.unpkg.sign;
    sign2 = op2.unpkg.sign;
    exp1 = op1.unpkg.exponent;
    exp2 = op2.unpkg.exponent;
    sig1 = op1.unpkg.significand;
    sig2 = op2.unpkg.significand;
    opcode = 1'b0;
    $display("op1: %1b %8b %23b. op2: %1b %8b %23b.", sign1, exp1, sig1, sign2, exp2, sig2);
    #120;
    out.bits = fp_out;
    out_sr = fpPack(out);
    $display("Result: %0f.", out_sr);
    $display("out: %1b %8b %23b", out.unpkg.sign, out.unpkg.exponent, out.unpkg.significand);

end

// 0 10000110 10010001100110011001101   200.8
// 0 10000110 00100011001100110011010

endmodule


// 110010001000000000000000000
// 000000000100110011001100111