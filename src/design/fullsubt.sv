module FullSubtractor(D, BO, A, B, BI);
    input wire A, B, BI;
    output logic D, BO;

    assign #1 D = (A ^ B) ^ BI;
    assign #1 BO = ~A & BI | ~A & B | B & BI;
    
endmodule