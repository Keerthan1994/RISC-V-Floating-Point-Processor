// cfaber - 5/16 Verified

module top ();

logic [7:0] exp1, exp2;
logic [22:0] sig1, sig2;
logic [7:0] exp1_d, exp2_d;
logic [1:0] n_concat;

denorm_zero dz0 (.*);


initial begin
    // Test non-zero exponents
    for (int i = 0; i < 10; i++) begin
        exp1 = {$random()} % 256;
        exp2 = {$random()} % 256;
        sig1 = $random();
        sig2 = $random();
        #10
        $display("exp1: %8b sig1: %23b exp1_d: %8b, exp2: %8b sig2: %23b exp2_d: %8b, n_concat: %2b", exp1, sig1, exp1_d, exp2, sig2, exp2_d, n_concat);
    end

    // Testing zero exponent
    for (int i = 0; i < 20; i++) begin
        exp1 = (i%3 == 0) ? '0 : $random();
        exp2 = (i%5 == 0) ? '0 : $random();
        sig1 = (i%2 == 0) ? $random(): '0;
        sig2 = (i%4 == 0) ? $random(): '0;
        #10
        $display("exp1: %8b sig1: %23b exp1_d: %8b, exp2: %8b sig2: %23b exp2_d: %8b, n_concat: %2b", exp1, sig1, exp1_d, exp2, sig2, exp2_d, n_concat);
    end

end

endmodule