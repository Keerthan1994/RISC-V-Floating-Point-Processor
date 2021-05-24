module postcomplement (
    complement, co_i, operand, op_comp, co_o
);

parameter N = 27;

input complement, co_i;
input [N-1:0] operand;
output logic [N-1:0] op_comp;
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