module denorm_zero (exp1, exp2, sig1, sig2, n_concat, exp1_d, exp2_d, sig1_o, sig2_o);

input [7:0] exp1, exp2;
input [22:0] sig1, sig2;
output [7:0] exp1_d, exp2_d;
output [22:0] sig1_o, sig2_o;
output [1:0] n_concat;

// If exoponent is zero, and sig is nonzero, set exponent to 1
if (exp1 == 8'b0) begin
    n_concat[1] = 1'b1;
    if (sig1 != 23'b0) begin
        exp1_d = 8'b1;
    end else begin
        exp1_d = exp1;
    end
end
if (exp2 == 8'b0) begin
    n_concat[0] = 1'b1;
    if (sig2 != 23'b0) begin
        exp2_d = 8'b1;
    end else begin
        exp2_d = exp2;
    end
end

endmodule