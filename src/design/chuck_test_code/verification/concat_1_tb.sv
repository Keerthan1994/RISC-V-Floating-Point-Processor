module top ();

logic [22:0] sig1, sig2;
logic [1:0] n_concat;
logic swap;
logic [23:0] sig1_concat, sig2_concat;

concat_1 cc1_0 (
    .sig1(), 
    .sig2(), 
    .n_concat(), 
    .swap(), 
    .sig1_concat(), 
    .sig2_concat()
);

initial begin
    
end

endmodule