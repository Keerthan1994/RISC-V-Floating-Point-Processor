module div_int_tb();

    parameter CLK_PERIOD = 10;  // 10 ns == 100 MHz
    parameter WIDTH = 4;

    logic clk;
    logic start;            // start signal
    logic busy;             // calculation in progress
    logic valid;            // quotient and remainder are valid
    logic dbz;              // divide by zero flag
    logic [WIDTH-1:0] x;    // dividend
    logic [WIDTH-1:0] y;    // divisor
    logic [WIDTH-1:0] q;    // quotient
    logic [WIDTH-1:0] r;    // remainder

    div_int #(.WIDTH(WIDTH)) div_int_inst (.*);

    always #(CLK_PERIOD / 2) clk = ~clk;

    initial begin
        $monitor("\t%d:\t%d /%d =%d (r =%d) (V=%b) (DBZ=%b)",
            $time, x, y, q, r, valid, dbz);
    end

    initial begin
        clk = 1;
		#100    x = 4'b1011;  // 11
                y = 4'b0011;  // 3
                start = 1;
        #10     start = 0;
		

        #100    x = 4'b0000;  // 0
                y = 4'b0010;  // 2
                start = 1;
        #10     start = 0;

        #100     x = 4'b0010;  // 2
                y = 4'b0000;  // 0
                start = 1;
        #10     start = 0;

        #100     x = 4'b0111;  // 7
                y = 4'b0010;  // 2
                start = 1;
        #10     start = 0;

        #100     x = 4'b1111;  // 15
                y = 4'b0101;  //  5
                start = 1;
        #10     start = 0;

        #100     x = 4'b0001;  // 1
                y = 4'b0001;  // 1
                start = 1;
        #10     start = 0;

        #100     x = 4'b1000;  // 8
                y = 4'b1001;  // 9
                start = 1;
        #10     start = 0;

      

        #100     $finish;
		
    end
endmodule
