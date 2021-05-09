import fp::*;

module add(input fp_t bin_val1, bin_val2, output fp_t bin_out);

    logic [22:0] sig1, sig2, csig1, csig2, swap_sig1, swap_sig2, aligned_sig2, adder_sum;
    logic [7:0] shift_by_bits;
    logic full_sub_bo, adder_CO;

    Nbit_FullSubtractor #(8) fs(shift_by_bits[7:0], full_sub_bo, bin_val1.unpkg.exponent, bin_val2.unpkg.exponent, 1'b0);
    complement co1(bin_val1.unpkg.significand, csig1);
    complement co2(bin_val2.unpkg.significand, csig2);
    assign sig1 = bin_val1.unpkg.sign ? bin_val1.unpkg.significand : csig1;
    assign sig2 = bin_val2.unpkg.sign ? bin_val2.unpkg.significand : csig2;

    assign swap_sig1 = full_sub_bo ? sig1 : sig2;
    assign swap_sig2 = full_sub_bo ? sig2 : sig1;

    align_significands a(swap_sig2, shift_by_bits, aligned_sig2);

    Nbit_FullAdder Add(adder_sum, adder_CO, swap_sig1, swap_sig2, 1'b0);

    // Normalize and round logic will update the output significand value
    assign bin_out.unpkg.significand = adder_sum;

    // Control and sign logic will update the output sign value
    // Another adder module should figure out why will update the output exponent value

endmodule