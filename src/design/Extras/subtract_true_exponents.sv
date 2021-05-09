module subtract_true_exponents(
    input [7:0] exp1, exp2, output int diff
);
    assign diff = exp1-exp2;
    // This module needs to subtract the two exponents (exp1 - exp2), and then 
    // depending on if the value is positive or negative output exp1 or exp2
    // and the absolute difference between the two exponents.
    // Diagram uses a full subtractor, dunno if this is what I wanna do.

endmodule
