// Verified 5/23 by inspection - CF and BC

module add_significands (
    sig1_cc, sig2_a, co, sum
);

input [26:0] sig1_cc, sig2_a;
output logic co;
output logic [26:0] sum;

nbit_fulladder #(27) fa_0 (
    .S(sum), 
    .CO(co), 
    .A(sig1_cc), 
    .B(sig2_a), 
    .CI(1'b0)
);

endmodule