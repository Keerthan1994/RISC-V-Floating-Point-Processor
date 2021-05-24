module postcomplement (
    complement, co_i, operand, op_comp, co_o
);

input complement, co_i;
input [26:0] operand;
output logic [26:0] op_comp;
output logic co_o;

always_comb begin
    if (complement && co_i) begin
        co_o = 0;
        op_comp = operand;
    end else if (complement && !co_i) begin
        op_comp = ~operand + 1;
        co_o = co_i;
    end else begin
        op_comp = operand;
        co_o = co_i;
    end
    // op_comp = complement ? ~operand + 1 : operand;
end

endmodule