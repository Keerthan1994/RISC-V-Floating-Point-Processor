module top();

logic carryout;
logic [26:0] sig, sig_norm;
logic [7:0] exp, shift;

normalize norm0 (.*);

initial begin

sig = $urandom();
exp = $urandom();
carryout = {$random()}%2;
#10;
$display("INPUTS: Sig: %27b. Exp: %3d. Carryout: %1b. OUTPUTS: Shift: %3d. Sig_Norm: %27b.", sig, 127-exp, carryout, $signed(shift), sig_norm);

end

endmodule