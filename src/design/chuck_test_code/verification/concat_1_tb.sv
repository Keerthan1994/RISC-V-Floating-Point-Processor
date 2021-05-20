// Cfaber - 5/16 - Module verified

module top ();

logic [22:0] sig1, sig2;
logic [1:0] n_concat;
logic swap;
logic [26:0] sig1_concat, sig2_concat;

concat_1 cc1_0 (.*);

initial begin
    for (int i = 0; i < 10; i++) begin
        sig1 = $random();
        sig2 = $random();
        n_concat = {$random()} % 4;
        swap = {$random()} % 2;
        #10
        $display("sig1: %23b sig2: %23b, nconcat: %2b, swap: %1b, sig1_concat: %27b, sig2_concat: %27b", sig1, sig2, n_concat, swap, sig1_concat, sig2_concat);
    end
end

endmodule