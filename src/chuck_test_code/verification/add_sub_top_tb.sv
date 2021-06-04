import addpkg::*;

module top();

// shortreal op1, op2, out;
shortreal out_sr;
// fp_t op1, op2, out;

logic sign1, sign2;
logic [7:0] exp1, exp2;
logic [22:0] sig1, sig2;
logic opcode;
logic [31:0] fp_out;
// logic [2:0] err_o;
o_err_t err_o;

FloatingPoint op1, op2, out, exp;

add_sub_top ast0 (.*);

initial begin
    op1 = new();
    op2 = new();
    out = new();
    exp = new();

    singleTestCase(op1, op2, exp, out, opcode, sign1, sign2, exp1, exp2, sig1, sig2, fp_out, err_o, REG, REG, 1'b0, 1'b0, 1'b0);

// Older Version
    // op1.generateNew(DENORM);
    // op2.generateNew(INF);
    // exp.setSR(op1.getSR - op2.getSR);
    // $display("Op1 Value: %0e. Op2 Value: %0e. Expected Value: %0e.", op1.getSR(), op2.getSR(), exp.getSR());

    // #10;
    // sign1 = op1.sign;
    // sign2 = op2.sign;
    // exp1 = op1.exponent;
    // exp2 = op2.exponent;
    // sig1 = op1.significand;
    // sig2 = op2.significand;
    // opcode = 1'b1;

    // #20;
    // out.setBits(fp_out);
    // $display("Resultant Value: %0e. Equal?: %0b", out.getSR(), out.equals(exp));

    // $monitor("swap: %01b complement: %01b exp_r1: %08b shift1: %08d shift2: %08d exp_r2: %08b shift3: %08d carry1: %1b carry2: %1b carry3: %1b carry4: %1b \nsig1_c: %027b sig2_c: %027b sig1_cc: %027b sig2_a: %027b sig_sum: %027b \nsig_pc: %027b sig_r: %27b \nresult: %1b %8b %027b\n", ast0.swap, ast0.complement, ast0.exp_r1, ast0.shift1, ast0.shift2, ast0.exp_r2, ast0.shift3, ast0.carry1, ast0.carry2, ast0.carry3, ast0.carry4, ast0.sig1_c, ast0.sig2_c, ast0.sig1_cc, ast0.sig2_a, ast0.sig_sum, ast0.sig_pc, ast0.sig_r, ast0.sign_r, ast0.exp_f, ast0.sig_f);

// Oldest Version
    // #10;
    // op1 = fpUnpack(2.0);
    // op2 = fpUnpack(2.0);
    // sign1 = op1.unpkg.sign;
    // sign2 = op2.unpkg.sign;
    // exp1 = op1.unpkg.exponent;
    // exp2 = op2.unpkg.exponent;
    // sig1 = op1.unpkg.significand;
    // sig2 = op2.unpkg.significand;
    // opcode = 1'b0;
    // $display("op1: %1b %8b %23b. op2: %1b %8b %23b.", sign1, exp1, sig1, sign2, exp2, sig2);
    // #20;
    // out.bits = fp_out;
    // out_sr = fpPack(out);
    // $display("Result: %0f.", out_sr);
    // $display("out: %1b %8b %23b", out.unpkg.sign, out.unpkg.exponent, out.unpkg.significand);

end

endmodule
