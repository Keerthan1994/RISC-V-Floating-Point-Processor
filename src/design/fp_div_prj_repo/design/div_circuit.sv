//divider



module div_int #(parameter WIDTH=4) (
    input wire logic clk,
    input wire logic start,          // start signal
    output     logic busy,           // calculation in progress
    output     logic valid,          // quotient and remainder are valid
    output     logic dbz,            // divide by zero flag
    input wire logic [WIDTH-1:0] x,  // dividend
    input wire logic [WIDTH-1:0] y,  // divisor
    output     logic [WIDTH-1:0] q,  // quotient
    output     logic [WIDTH-1:0] r   // remainder
    );

    logic [WIDTH-1:0] y1;            // copy of divisor
    logic [WIDTH-1:0] q1, q1_next;   // intermediate quotient
    logic [WIDTH:0] ac, ac_next;     // accumulator (1 bit wider)
    int i;     // iteration counter

    always_comb begin
		
        if(ac[WIDTH]) begin
			{ac_next, q1_next} = {ac, q1} << 1;
			//$display("if1 ac_next=%x, q1_next=%x", ac_next, q1_next);
			ac_next = ac_next + y1;
			//$display("if2 ac_next=%x, q1_next=%x", ac_next, q1_next);
		end
		else begin
			//$display("comb else1 ac=%x, q1=%x", ac, q1);
			{ac_next, q1_next} = {ac, q1} << 1;	
			//$display("else1 ac_next=%x, q1_next=%x", ac_next, q1_next);
			ac_next = ac_next - y1;	
			//$display("else2 ac_next=%x, q1_next=%x", ac_next, q1_next);			
		end
    end

    always_ff @(posedge clk) begin
        if (start) begin
            valid <= 0;
            i <= WIDTH;
            if (y == 0) begin //If divide by zero
                busy <= 0;
                dbz <= 1;
				q <= 0;
				r <= 0;
			end else if (x == 0) begin
				busy <= 0;
				dbz <= 0;
				q <= 0;
				r <= 0;
            end else if (x < y) begin
				busy <= 0;
				dbz <= 0;
				q <= 0;
				r <= x;
			end else begin  
                busy <= 1;
                dbz <= 0;
                y1 <= y;
                {ac, q1} <= {{WIDTH{1'b0}}, 1'b0, x};
				//$display("initial ac=%x, q1=%x", ac, q1);
            end
        end else if (busy) begin
            if (i == 0) begin  
                busy <= 0;
                valid <= 1;
                q <= q1;
                r <= ac[WIDTH:0];  
            end else begin  
                i <= i - 1;
				//$display("ac_next=%x, q1_next=%x", ac_next, q1_next);
				if (ac_next[WIDTH]) begin
					{ac, q1} <= {ac_next[WIDTH:0], q1_next[WIDTH-1:1], 1'b0};
					//$display("if ac=%x, q1=%x", ac, q1);
				end
				else begin
					{ac, q1} <= {ac_next[WIDTH:0], q1_next[WIDTH-1:1], 1'b1};
					//$display("else ac=%x, q1=%x", ac, q1);
				end
            end
        end
    end
endmodule
