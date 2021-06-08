// Verified 5/23 by inspection - CF and BC
parameter SIG_BITS = 23;
parameter EXP_BITS = 8;
module add_significands (
    sig1_cc, sig2_a, co, sum
);

input [SIG_BITS+3:0] sig1_cc, sig2_a;
output logic co;
output logic [SIG_BITS+3:0] sum;

nbit_fulladder #(SIG_BITS+4) fa_0 (
    .S(sum), 
    .CO(co), 
    .A(sig1_cc), 
    .B(sig2_a), 
    .CI(1'b0)
);

endmodule