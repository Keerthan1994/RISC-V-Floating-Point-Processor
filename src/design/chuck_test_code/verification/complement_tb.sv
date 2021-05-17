// cfaber - 5/16 module verified

module top();

logic complement;
logic [23:0] operand;
logic [23:0] op_comp;

complement comp0 (.*);

initial begin
    for (int i = 0; i < 10; i++) begin
        complement = {$random()} % 2;
        operand = $random();
        #10
        $display("complement: %1b; operand: %24b; result: %24b", complement, operand, op_comp);
    end
end

endmodule