import addpkg::*;

module top();

    shortreal val;

    initial begin
        val = 0.25;
        FpUnpackTest(val);
        val = -0.25;
        FpUnpackTest(val);
    end

endmodule