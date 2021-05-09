module top();
    logic [22:0] significand;
    logic [22:0] complemented_significand;
    complement c(significand, complemented_significand);
    initial begin
        significand=23'b00000000000000000000000;
        #5$display("Output of complement: %b", complemented_significand);
        #5 significand=23'b10010000000000000000000;
        #5$display("Output of complement: %b", complemented_significand);
    end

endmodule