// 5/23/2021 - Verified by test CF and BC

module top();

logic complement, co_o, CO, CI;
logic [7:0] op_comp;
logic [7:0] S, A, B;

Nbit_FullAdder #(8) fa0 (.*);
postcomplement #(8) pc0 (
    .operand(S),
    .co_i(CO),
    .*
    );

initial begin
    complement = 0;
    A = 255;
    B = 1;
    CI = 0;
    if (complement) begin
        A = ~A + 1;
    end

    #10;
    $display("INPUTS: A: %0d. B: %0d. Comp: %1b. OUTPUTS: CO_I: %0b. Sum: %0d. Op_Comp: %0d. CO_O: %0b.", $signed(A), $signed(B), complement, CO, $signed(S), $signed(op_comp), co_o);
end

endmodule