import addpkg_div::*;

module fdiv_newton (a,b,rm,fdiv,ena,clk,rstn, s,busy,stall,count,reg_x,err_o);
	parameter ZERO = 31'h00000000;
	parameter INF = 31'h7f800000;
	parameter NaN = 31'h7fc00000;
	parameter MAX = 31'hf7fffff;
	
	input logic [31:0] a,b; // fp s = a / b
	input logic [1:0] rm; // round mode
	input logic fdiv; // ID stage: fdiv = i_fdiv
	input logic ena; // enable
	input logic clk, rstn; // clock and reset
	output logic [31:0] s; // fp output
	output logic [25:0] reg_x; // x_i
	output logic [4:0] count; // for iteration control
	output logic busy; // for generating stall
	output logic stall; // for pipeline stall
	output o_err_t err_o; //set the error signal
	
	logic a_expo_is_00; 
	logic b_expo_is_00;
	logic a_expo_is_ff;
	logic a_frac_is_00;
	logic b_frac_is_00;
	logic b_expo_is_ff;
	logic sign;
	assign a_expo_is_00 = ~|a[30:23];
	assign b_expo_is_00 = ~|b[30:23];
	assign a_expo_is_ff = &a[30:23];
	assign b_expo_is_ff = &b[30:23];
	assign a_frac_is_00 = ~|a[22:0];
	assign b_frac_is_00 = ~|b[22:0];
	assign sign = a[31] ^ b[31];
	logic [9:0] exp_10;
	logic [23:0] a_temp24;
	logic [23:0] b_temp24;
	assign exp_10 = {2'h0,a[30:23]} - {2'h0,b[30:23]} + 10'h7f;
	assign a_temp24 = a_expo_is_00? {a[22:0],1'b0} : {1'b1,a[22:0]};
	assign b_temp24 = b_expo_is_00? {b[22:0],1'b0} : {1'b1,b[22:0]};
	logic [23:0] a_frac24,b_frac24; // to 1xx...x for denormalized number
	logic [4:0] shamt_a,shamt_b; // how many bits shifted
	shift_to_msb_equ_1 shift_a (a_temp24,a_frac24,shamt_a); // to 1xx...xx
	shift_to_msb_equ_1 shift_b (b_temp24,b_frac24,shamt_b); // to 1xx...xx
	logic [9:0] exp10;
	assign exp10 = exp_10 - shamt_a + shamt_b;
	logic e1_sign,e1_ae00,e1_aeff,e1_af00,e1_be00,e1_beff,e1_bf00;
	logic e2_sign,e2_ae00,e2_aeff,e2_af00,e2_be00,e2_beff,e2_bf00;
	logic e3_sign,e3_ae00,e3_aeff,e3_af00,e3_be00,e3_beff,e3_bf00;
	logic [1:0] e1_rm,e2_rm,e3_rm;
	logic [9:0] e1_exp10,e2_exp10,e3_exp10;
	

		

	always_ff @ (negedge rstn or posedge clk)
	if (!rstn) 
	begin // 3 pipeline registers: reg_e1, reg_e2, and reg_e3
	// reg_e1 // reg_e2 // reg_e3
		e1_sign <= 0; e2_sign <= 0; e3_sign <= 0;
		e1_rm <= 0; e2_rm <= 0; e3_rm <= 0;
		e1_exp10<= 0; e2_exp10<= 0; e3_exp10<= 0;
		e1_ae00 <= 0; e2_ae00 <= 0; e3_ae00 <= 0;
		e1_aeff <= 0; e2_aeff <= 0; e3_aeff <= 0;
		e1_af00 <= 0; e2_af00 <= 0; e3_af00 <= 0;
		e1_be00 <= 0; e2_be00 <= 0; e3_be00 <= 0;
		e1_beff <= 0; e2_beff <= 0; e3_beff <= 0;
		e1_bf00 <= 0; e2_bf00 <= 0; e3_bf00 <= 0;
	end 
	else if (ena) begin
		e1_sign <= sign; e2_sign <= e1_sign; e3_sign <= e2_sign;
		e1_rm <= rm; e2_rm <= e1_rm; e3_rm <= e2_rm;
		e1_exp10<= exp10; e2_exp10<= e1_exp10; e3_exp10<= e2_exp10;
		e1_ae00 <= a_expo_is_00; e2_ae00 <= e1_ae00; e3_ae00 <= e2_ae00;
		e1_aeff <= a_expo_is_ff; e2_aeff <= e1_aeff; e3_aeff <= e2_aeff;
		e1_af00 <= a_frac_is_00; e2_af00 <= e1_af00; e3_af00 <= e2_af00;
		e1_be00 <= b_expo_is_00; e2_be00 <= e1_be00; e3_be00 <= e2_be00;
		e1_beff <= b_expo_is_ff; e2_beff <= e1_beff; e3_beff <= e2_beff;
		e1_bf00 <= b_frac_is_00; e2_bf00 <= e1_bf00; e3_bf00 <= e2_bf00;
	end
	logic [31:0] q; // af24 / bf24 = 1.xxxxx...x or 0.1xxxx...x
	newton24 frac_newton (a_frac24,b_frac24,fdiv,ena,clk,rstn,q,busy,count,reg_x,stall);
	logic [31:0] z0;
	logic [9:0] exp_adj;
	assign z0 = q[31] ? q : {q[30:0],1'b0}; // 1.xxxxx...x
	assign exp_adj = q[31] ? e3_exp10 : e3_exp10 - 10'b1;
	logic [9:0] exp0;
	logic [31:0] frac0;
	always_comb begin
		if (exp_adj[9]) begin // exp is negative
			exp0 = 0;
			if (z0[31]) // 1.xx...x
				frac0 = z0 >> (10'b1 - exp_adj); // denormalized (-126)
			else 
				frac0 = 0;
		end 
		else if (exp_adj == 0) begin // exp is 0
			exp0 = 0;
			frac0 = {1'b0,z0[31:2],|z0[1:0]}; // denormalized (-126)
		end 
		else begin // exp > 0
			if (exp_adj > 254) begin // inf
				exp0 = 10'hff;
				frac0 = 0;
			end 
			else begin // normalized
				exp0 = exp_adj;
				frac0 = z0;
			end
		end
	end
	logic [26:0] frac;
	wire frac_plus_1;
	logic [24:0] frac_round;
	logic [9:0] exp1;
	logic overflow;
	assign frac = {frac0[31:6],|frac0[5:0]}; // sticky
	assign frac_plus_1 =
		~e3_rm[1] & ~e3_rm[0] &  frac[3] &  frac[2] & ~frac[1]  & ~frac[0] |
		~e3_rm[1] & ~e3_rm[0] &  frac[2] & (frac[1] |  frac[0]) |
		~e3_rm[1] &  e3_rm[0] & (frac[2] |  frac[1] |  frac[0]) &  e3_sign |
		 e3_rm[1] & ~e3_rm[0] & (frac[2] |  frac[1] |  frac[0]) & ~e3_sign;
	assign frac_round = {1'b0,frac[26:3]} + frac_plus_1;
	assign exp1 = frac_round[24]? exp0 + 10'h1 : exp0;
	assign overflow = (exp1 >= 10'h0ff); // overflow
	logic [7:0] exponent;
	logic [22:0] fraction;
	/*
	assign {exponent,fraction} = final_result({overflow,e3_rm,e3_sign,
		e3_ae00,e3_aeff,e3_af00,e3_be00,e3_beff,
		e3_bf00},{exp1[7:0],frac_round[22:0]});
		*/
	assign {exponent,fraction} = final_result({overflow,e1_rm,e1_sign,
		e1_ae00,e1_aeff,e1_af00,e1_be00,e1_beff,
		e1_bf00},{exp1[7:0],frac_round[22:0]});
	assign s = {e3_sign,exponent,fraction};
	
	always_comb begin
		if (b == 0) err_o = DIVBYZERO;
		else if(s[30:23] == 8'hFF && s[22:0] == 0) err_o = OVERFLOW;
		else if (s[30:23] == 8'hFF && s[22:0] != 0) err_o = INVALID;
		else if (s[30:23] == 8'h00 && s[22:0] != 0) err_o = UNDERFLOW;
		else err_o = NONE;
	end
	/*
	initial begin
		$monitor("exponent=%h, fraction=%h, overflow=%h, e3_rm=%h ,e3_sign=%h, a_e00=%h , a_eff=%h, a_f00=%h, b_e00=%h, b_eff=%h, b_f00=%h, exp1=%h, frac_round=%h", 
				exponent,fraction, overflow,e3_rm,e3_sign,e3_ae00,e3_aeff,e3_af00,e3_be00,e3_beff,e3_bf00, exp1, frac_round);
	end
	*/
	function [30:0] final_result(input [9:0] sel, input [30:0] calc);
			if(sel ==? 10'b100?_???_??? || sel ==? 10'b1011_???_??? || sel ==? 10'b1100_???_??? || sel ==? 10'b0???_011_101 || sel ==? 10'b0???_100_101 || sel ==? 10'b0???_00?_101
			   || sel ==? 0'b0???_011_100 || sel ==? 10'b0???_011_00?) begin
				final_result = INF;
				
			end
			else if (sel ==? 10'b1010_???_??? || sel ==? 10'b1101_???_??? || sel ==? 10'b111?_???_???) begin
				final_result = MAX;
				
			end
			else if(sel ==? 0'b0???_010_??? || sel ==? 10'b0???_011_010 || sel ==? 10'b0???_100_010 || sel ==? 10'b0???_101_010 || sel ==? 10'b0???_00?_010 || sel ==? 10'b0???_011_011 || sel ==? 10'b0???_101_101) begin
				final_result = NaN;
				
			end
			else if(sel ==? 10'b0???_100_011 || sel ==? 10'b0???_101_011 || sel ==? 10'b0???_00?_011 || sel ==? 10'b0???_101_100 || sel ==? 10'b0???_101_00?) begin
				final_result = ZERO;
				
			end
			else if(sel ==? 10'b0???_100_100 || sel ==? 10'b0???_00?_100 || sel ==? 10'b0???_100_00? || sel ==? 10'b0???_00?_00?)	begin
				final_result = calc;
				
			end
			else begin 
				final_result = ZERO;
				
			end
			
	endfunction
	
	
endmodule



