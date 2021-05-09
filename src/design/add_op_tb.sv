import fp::*;

module top();

    shortreal val1, val2, exp1, exp2, sig1, sig2;
    int shift_value;
    fp_t bin_val1, bin_val2, bin_out;
    add a(bin_val2, bin_val2, bin_out);
    initial begin
        val1 = 0.25;
        bin_val1 = fpUnpack(val1); 
        val2 = 100;
        bin_val2 = fpUnpack(val2);
        #5$display(" Input values: %p and %p, Output is: %p", bin_val1, bin_val2, bin_out);
    end

endmodule