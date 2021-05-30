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

module add_sub_top(.*);

initial begin
    #10;
    op1 = fpUnpack(2.5);
    op2 = fpUnpack(0.3);
    sign1 = op1.unpkg.sign;
    sign2 = op2.unpkg.sign;
    exp1 = op1.unpkg.exponent;
    exp2 = op2.unpkg.exponent;
    sig1 = op1.unpkg.significand;
    sig2 = op2.unpkg.significand;
    opcode = 1'b0;
    #10;
    out.bits = fp_out;
    out_sr = fpPack(out);
    $display("Result: %0f.", out_sr);
end

endmodule