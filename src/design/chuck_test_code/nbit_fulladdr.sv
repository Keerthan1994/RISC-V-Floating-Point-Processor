module Nbit_FullAdder(S, CO, A, B, CI);
    parameter N=23;
    input wire[N-1:0] A, B;
    input wire CI;
    output logic [N-1:0] S;
    output CO;
    logic [N:0] CO_p;
    assign CO_p[0]=CI;

    genvar r;
    generate
    for (r = 0; r < N; r++)
    begin
        FullAdder s(S[r], CO_p[r+1], A[r], B[r], CO_p[r]);
    end
    endgenerate
    assign CO = CO_p[N];

endmodule