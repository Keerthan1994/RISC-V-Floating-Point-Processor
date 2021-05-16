module Nbit_FullSubtractor(D, BO, A, B, BI);
    parameter N=8;
    input wire[N-1:0] A, B;
    input wire BI;
    output logic [N-1:0] D;
    output BO;
    logic [N:0] BO_p;
    assign BO_p[0]=BI;

    genvar r;
    generate
    for (r = 0; r < N; r++)
    begin
        FullSubtractor s(D[r], BO_p[r+1], A[r], B[r], BO_p[r]);
    end
    endgenerate
    assign BO = BO_p[N];

endmodule