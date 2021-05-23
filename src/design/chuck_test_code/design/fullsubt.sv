module FullSubtractor(D, BO, A, B, BI);
    input wire A, B, BI;
    output logic D, BO;

    assign D = (A ^ B) ^ BI;
    assign BO = ~A & BI | ~A & B | B & BI;
    
endmodule