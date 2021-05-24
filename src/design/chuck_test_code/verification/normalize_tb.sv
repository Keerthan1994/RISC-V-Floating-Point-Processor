// 5/23/2021 Verified by CF and BC

module top();

logic carryout;
logic [26:0] sig, sig_norm;
logic [7:0] exp, shift;

normalize norm0 (.*);

initial begin

    for (int i = 0; i < 10; i++) begin
        sig = $urandom();
        exp = $urandom() & 8'hFF;
        carryout = {$random()}%2;
        #10;
        $display("INPUTS: Sig: %27b. Exp: %3d. Carryout: %1b. OUTPUTS: Shift: %3d. Sig_Norm: %27b.", sig, exp, carryout, $signed(shift), sig_norm);
    end

    for (int i = 0; i < 10; i++) begin
        sig = $urandom() & 20'hFFFFF;
        exp = $urandom() & 8'hFF;
        carryout = 0;
        #10;
        $display("INPUTS: Sig: %27b. Exp: %3d. Carryout: %1b. OUTPUTS: Shift: %3d. Sig_Norm: %27b.", sig, exp, carryout, $signed(shift), sig_norm);
    end
end

endmodule