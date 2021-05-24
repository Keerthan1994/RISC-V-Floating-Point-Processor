
module top();

logic [26:0] sig_n, sig_r;
logic co;

rounding r0 (.*);

initial begin
    for (int i = 0; i < 10; i++) begin
        sig_n = $urandom();
        for(int j = 0; j < 8; j++) begin
            sig_n[2:0] = j;
            #10;
            $display("IN: sig_n: %24b %3b. co: %1b. OUT: sig_r: %24b %3b.", sig_n[26:3], sig_n[2:0], co, sig_r[26:3], sig_r[2:0]);
        end
    end
end

endmodule