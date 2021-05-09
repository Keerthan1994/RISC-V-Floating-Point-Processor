module top();

    logic [7:0] exp1, exp2;
    logic [31:0] diff;
    subtract_true_exponents s(exp1, exp2, diff);
    initial begin
        exp1=8'b01111101;
        exp2=8'b10000101;
        #5$display("Output of subtract_true_exponents: %d", diff);
    end

endmodule