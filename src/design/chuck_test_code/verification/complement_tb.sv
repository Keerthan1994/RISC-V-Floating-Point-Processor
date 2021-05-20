// cfaber - 5/16 module verified

module top();

logic complement;
logic [26:0] operand;
logic [26:0] op_comp;

complement comp0 (.*);

initial begin
    for (int i = 0; i < 10; i++) begin
        complement = {$random()} % 2;
        operand = $random();
        #10
        $display("complement: %1b; operand: %27b; result: %27b", complement, operand, op_comp);
    end
end

endmodule