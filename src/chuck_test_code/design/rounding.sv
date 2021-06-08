// 5/23/2021 - Verified by CF and BC
parameter SIG_BITS = 23;
parameter EXP_BITS = 8;
module rounding (
    sig_n, sig_r, co
    );

    input [SIG_BITS+3:0] sig_n;
    output logic [SIG_BITS+3:0] sig_r;
    output logic co;
    logic [SIG_BITS+1:0] sig_tmp;

    always_comb begin
        if (!sig_n[2]) begin                                                // Truncate Case
            sig_tmp = sig_n[SIG_BITS+3:3];
        end else if (!sig_n[3] && sig_n[2] && !sig_n[1] && !sig_n[0]) begin // Round to Even Case
            sig_tmp = sig_n[SIG_BITS+3:3];
        end else begin                                                      // Round Up Case
            sig_tmp = sig_n[SIG_BITS+3:3] + 1;
        end
        co = sig_tmp[SIG_BITS+1];
        sig_r = {sig_tmp[SIG_BITS:0], 3'b000};
    end

endmodule