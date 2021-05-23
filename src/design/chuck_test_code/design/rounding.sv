module rounding (
    sig_n, sig_nr
    );

    input [26:0] sig_n;
    output [22:0] sig_nr;
    logic [24:0] sig_tmp;

    always_comb begin
        if (!sig_n[2]) begin
            sig_tmp[23:0] = sig_n[26:3];
        end else if (!sig_n[3] && sig_n[2] && !sig_n[1] && !sig_n[0]) begin
            sig_tmp[23:0] = sig_n[26:3];
        end else begin
            sig_tmp = sig_n[26:3] + 1;
        end

        if (sig_tmp[24]) begin
            // we need to normalize
        end else begin
            sig_nr = sig_tmp[22:0];
        end
    end

endmodule