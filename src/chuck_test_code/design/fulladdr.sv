module fulladder(S, CO, A, B, CI);
    input wire A, B, CI;
    output logic S, CO;

    assign S = A ^ B ^ CI;
    assign CO = A & B | A & CI | B & CI;
    
endmodule