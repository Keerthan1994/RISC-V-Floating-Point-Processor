// 5/23/2021 - Verified by CF and BC

module rounding (
    sig_n, sig_r, co
    );

    input [26:0] sig_n;
    output logic [26:0] sig_r;
    output logic co;
    logic [24:0] sig_tmp;

    always_comb begin
        if (!sig_n[2]) begin                                                // Truncate Case
            sig_tmp = sig_n[26:3];
        end else if (!sig_n[3] && sig_n[2] && !sig_n[1] && !sig_n[0]) begin // Round to Even Case
            sig_tmp = sig_n[26:3];
        end else begin                                                      // Round Up Case
            sig_tmp = sig_n[26:3] + 1;
        end
        co = sig_tmp[24];
        sig_r = {sig_tmp[23:0], 3'b000};
    end

endmodule