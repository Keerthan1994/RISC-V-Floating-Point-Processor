// 5/23/2021 - Verified by CF and BC

parameter SIG_BITS = 23;
parameter EXP_BITS = 8;
module top();

logic [SIG_BITS+3:0] sig2, sig2_aligned;
logic [EXP_BITS-1:0] shift;

align_significands as0 (.*);


initial begin
    for (int j=0; j<2; j++) begin
        sig2 = $urandom() & 27'b111111111111111111111000000;
        for (int i = 0; i < 15; i++) begin
            shift = i;
            #10;
            $display("Sig = %24b %3b, shift = %3d, sig_aligned = %24b %3b", sig2[26:3], sig2[2:0], shift, sig2_aligned[26:3], sig2_aligned[2:0]);
        end
        $write("\n");
    end
end

endmodule