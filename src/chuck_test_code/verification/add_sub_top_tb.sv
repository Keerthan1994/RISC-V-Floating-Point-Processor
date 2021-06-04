import addpkg::*;

module top();

parameter NTESTS = 1;

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
int err_count;

FloatingPoint op1, op2, out, exp;

fp_case op1_case, op2_case;
logic [3:0] sign_tc;    // {opcode, op1_sign, op2_sign}

// Instantiate ADD/SUB Module
add_sub_top ast0 (.*);

task automatic singleTestCase (
    ref FloatingPoint op1, op2, exp, out,                                             // Declared FloatingPoint Objects
        logic opcode, sign1, sign2, logic [7:0] exp1, exp2, logic [22:0] sig1, sig2,        // Ports linked to add/sub module
        logic [31:0] fp_out, o_err_t err_o,
        int err_count,
    input fp_case op1_case, op2_case, bit addsub_op, op1_sign, op2_sign                    // Non-Pass-by-Ref Variables
    );
    o_err_t exp_err;

    // Setup Operands and Calculate Expected Value
    op1.generateNew(op1_case);
    op2.generateNew(op2_case);
    op1.setSign(op1_sign);
    op2.setSign(op2_sign);
    unique case (addsub_op)
        1'b0: exp.setSR(op1.getSR + op2.getSR);
        1'b1: exp.setSR(op1.getSR - op2.getSR);
    endcase
    exp_err = expectedErrorCode(exp);
    sign1 = op1.sign;
    sign2 = op2.sign;
    exp1 = op1.exponent;
    exp2 = op2.exponent;
    sig1 = op1.significand;
    sig2 = op2.significand;
    opcode = addsub_op;

    // DELAY HERE
    #50;

    out.setBits(fp_out);
    if (!out.equals(exp)) begin
        $display("%0t::VALUE/TYPE MISMATCH: OP1=%0e %0s. OP2=%0e %0s. OP_CODE=%0b. EXP=%0e. RES=%0e. EXP_TYPE=%0s. RES_TYPE=%0s.", $time, op1.getSR(), op1.op_case.name(), op2.getSR(), op2.op_case.name(), addsub_op, exp.getSR(), out.getSR(), exp.op_case.name(), out.op_case.name());
        $display("Internal Error: %0s. Final Carry: %01b", ast0.err_i.name(), ast0.carry5);
        $display("EXP_BITS=%0s.", exp.bitsToString());
        $display("RES_BITS=%0s.", out.bitsToString());
        // $display("%1b %8b %27b Carry: %1b", ast0.sign_r, ast0.exp_f, ast0.sig_f, ast0.carry5);
        err_count++;
    end
    // if (err_o !== exp_err) begin
    //     $display("%0t::ERROR CODE MISMATCH: OP1=%0e. OP2=%0e. OP_CODE=%0b. EXP_ERR=%0s. RES_ERR=%0s.", $time(), op1.getSR(), op2.getSR(), addsub_op, exp_err.name(), err_o.name());
    // end

    `ifdef DEBUG
    $display("%0t: OP1=%0e. OP2=%0e. OP_CODE=%0b. EXP=%0e. RES=%0e. EXP_TYPE=%0s. RES_TYPE=%0s. EXP_ERR=%0s. RES_ERR=%0s.", $time, op1.getSR(), op2.getSR(), addsub_op, exp.getSR(), out.getSR(), exp.op_case.name(), out.op_case.name(), exp_err.name(), err_o.name());
    `endif

endtask

initial begin
    op1 = new();
    op2 = new();
    out = new();
    exp = new();

    op1_case = op1_case.first;
    op2_case = op2_case.first;
    sign_tc = '0;

// Full Test
do begin
    do begin
        for (sign_tc = 0; sign_tc < 8; sign_tc++) begin
            for (int i = 0; i < NTESTS; i++) begin
                singleTestCase(op1, op2, exp, out, opcode, sign1, sign2, exp1, exp2, sig1, sig2, fp_out, err_o, err_count, op1_case, op2_case, sign_tc[2], sign_tc[1], sign_tc[0]);
            end
        end
        op2_case = op2_case.next;
    end while(op2_case != op2_case.first);
    op1_case = op1_case.next;
end while(op1_case != op1_case.first);
$display("Total Error Count: %0d.", err_count);

// Test Two Regs but all signs
// for (sign_tc = 0; sign_tc < 8; sign_tc++) begin
//     for (int i = 0; i < 10; i++) begin
//         singleTestCase(op1, op2, exp, out, opcode, sign1, sign2, exp1, exp2, sig1, sig2, fp_out, err_o, op1_case, op2_case, sign_tc[2], sign_tc[1], sign_tc[0]);
//     end
// end

// Test only adding two positives, but all different corner cases
// do begin
//     do begin
//         singleTestCase(op1, op2, exp, out, opcode, sign1, sign2, exp1, exp2, sig1, sig2, fp_out, err_o, op1_case, op2_case, sign_tc[2], sign_tc[1], sign_tc[0]);
//         op2_case = op2_case.next;
//     end while(op2_case != op2_case.first);
//     op1_case = op1_case.next;
// end while(op1_case != op1_case.first);

// Single TestCase Test
// singleTestCase(op1, op2, exp, out, opcode, sign1, sign2, exp1, exp2, sig1, sig2, fp_out, err_o, op1_case, op2_case, 1'b0, 1'b0, 1'b0);

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
