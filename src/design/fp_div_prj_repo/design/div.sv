module newton (dividend,divisor,start,clk,rst,quotient,busy,ready,count);
	input logic [31:0] dividend; // dividend: .1xxx...x
	input logic [31:0] divisor; // divisor: .1xxx...x
	input logic start; // start
	input logic clk, rst; // clock and reset
	output logic [31:0] quotient; // quotient: x.xxx...x
	output logic busy; // busy
	output logic ready; // ready
	output logic [1:0] count; // counter
	logic [33:0] reg_x; // xx.xxxxx...xx
	logic [31:0] reg_a; // .1xxxx...xx
	logic [31:0] reg_b; // .1xxxx...xx
	// x_{i+1} = x_i * (2 - x_i * divisor)
	logic [65:0] axi;
	logic [65:0] bxi;
	logic [33:0] b34;
	logic [67:0] x68;
	logic [7:0] x0;
	assign quotient = axi[64:33] + |axi[32:30]; // rounding up
	
	/*
	initial begin
		$monitor("axi=%d, bxi=%d, b34=%d, x68=%d, x0=%d, quotient=%d, divididend=%h, divisor=%h",
				axi, bxi, b34, x68, x0,quotient, dividend, divisor);
	end
	*/
	always_comb 
	begin
		axi = reg_x * reg_a; // xx.xxxxx...x
		bxi = reg_x * reg_b; // xx.xxxxx...x
		b34 = ~bxi[64:31] + 1'b1; //x.xxxx...x
		x68 = reg_x * b34; // xxx.xxxxx...x
		x0 = check(divisor[30:27]);
	end
	
	always_ff @(posedge clk or negedge rst) begin
		if (!rst) begin
			busy <= 0;
			ready <= 0;
		end else begin
			if (start) begin
				reg_a <= dividend; // .1xxxx...x
				reg_b <= divisor; // .1xxxx...x
				reg_x <= {2'b1,x0,24'b0}; // 01.xxxx0...0
				busy <= 1;
				ready <= 0;
				count <= 0;
			end else begin
				reg_x <= x68[66:33]; // xx.xxxxx...x
				count <= count + 2'b1; // count++
			if (count == 2'h2) begin // 3 iterations
				busy <= 0;
				ready <= 1; // quotient is ready
			end
			end
		end
	end
	function logic [7:0] check(input [3:0] divisor); //checker table
		case (divisor) 
			4'h0: check = 8'hff; 
			4'h1: check = 8'hdf;
			4'h2: check = 8'hc3; 
			4'h3: check = 8'haa;
			4'h4: check = 8'h93; 
			4'h5: check = 8'h7f;
			4'h6: check = 8'h6d; 
			4'h7: check = 8'h5c;
			4'h8: check = 8'h4d; 
			4'h9: check = 8'h3f;
			4'ha: check = 8'h33; 
			4'hb: check = 8'h27;
			4'hc: check = 8'h1c; 
			4'hd: check = 8'h12;
			4'he: check = 8'h08; 
			4'hf: check = 8'h00;
		endcase
		return check;
	endfunction
endmodule