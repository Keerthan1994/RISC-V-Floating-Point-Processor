module fulladder(S, CO, A, B, CI);
    input wire A, B, CI;
    output logic S, CO;

    assign #1 S = A ^ B ^ CI;
    assign #1 CO = A & B | A & CI | B & CI;
    
endmodule