// Floating point multiplier
// 

module fp_multiplier(in_A,in_B,strb_A,strb_B,out_prod_ack,clk,reset_n,output_prod,output_prod_stb,in_A_ack,in_B_ack);
  
  input clk;
  input reset_n; 
  input [31:0] in_A ;
  input strb_A;
  output in_A_ack;  
  input [31:0] in_B ;
  input strb_B;
  output in_B_ack;
  output [31:0] output_prod;
  output output_prod_stb;
  input out_prod_ack;
    
  reg s_outprod_stb;
  reg [31:0] s_out_prod;
  reg s_in_a_ack;
  reg s_in_b_ack;
  
  
  reg [3:0] state;
  
  parameter get_A = 4'b0000,
            get_B = 4'b0001,
            unpack =  4'b0010,
            splcase = 4'b0011,
            normA = 4'b0100,
            normB = 4'b0101,
            MulA = 4'b0110,
            MulB = 4'b0111,
            norm1 = 4'b1000,
            norm2 = 4'b1001,
            round = 4'b1010,
            pack = 4'b1011,
            putz = 4'b1100;
  
  
  
  reg [31:0] x,y,z;
  reg [23:0] x_m,y_m,z_m;
  reg [9:0] x_e,y_e,z_e;
  reg x_s,y_s,z_s;
  reg guard, round_bit, sticky;
  reg [49:0] prod;

  
  
  always@(posedge clk) begin
      
  case(state)
        
  get_A : begin
      s_in_a_ack <= 1;
      if(s_in_a_ack && strb_A) begin
        x <= in_A;
        s_in_a_ack <= 0;
        state <= get_B;
      end
    end
    
    
    get_B: begin 
        s_in_b_ack <= 1;
        if(s_in_b_ack && strb_B) begin
        y <= in_B;
        s_in_b_ack <= 0;
        state <= unpack;
      end
    end
    
    unpack:begin
            x_m <= x[22:0];
            y_m <= y[22:0];
            x_e <= x[30:23] - 127;
            y_e <= y[30:23] - 127;
            x_s <= x[31];
            y_s <= y[31];
            state <= splcase;
        end
    
    
    splcase: begin
        
    // Case 1:return NaN
        if((x_e == 128 && x_m != 0) || (y_e == 128 && y_m != 0)) begin
          z[31] <= 1;
          z[30:23] <= 255;
          z[22] <= 0;
          state <= putz;
        end else if (x_e == 128) begin
          z[31] <= 1;
          z[30:23] <= 255;
          z[22] <= 1;
          
          if(($signed(y_e) == -127) && (y_m == 0)) begin
            z[31] <=1;
            z[30:23] <=255;
            z[22] <= 1;
            z[21:0] <= 0;
            
          end
          state <= putz;
          
        end else if (y_e == 128) begin
          z[31] <= 1;
          z[30:23] <= 255;
          z[22] <= 1;
          
          if(($signed(x_e) == -127) && (x_m == 0)) begin
            z[31] <=1;
            z[30:23] <=255;
            z[22] <= 1;
            z[21:0] <= 0;    
          end
          state <= putz;
          
          
        end else if (($signed(x_e) == -127) && (x_m == 0)) begin
          z[31] <= x_s ^ y_s;
          z[31:23] <= 0;
          z[22:0] <= 0;
          state <=putz;
          
        end else if (($signed(y_e) == -127) && (y_m == 0)) begin
          z[31] <= x_s ^ y_s;
          z[31:23] <= 0;
          z[22:0] <= 0;
          state <=putz;
        end else begin
          
          
          if ($signed(x_e) == -127) begin
            x_e <= -126;
          end else begin
            x_m[23] <= 1;
          end
          //Denormalised Number
          if ($signed(y_e) == -127) begin
            y_e <= -126;
          end else begin
            y_m[23] <= 1;
          end
          state <= normA;
        end
      end
          
    normA:begin
        if (x_m[23]) begin
          state <= normB;
        end else begin
          x_m <= x_m << 1;
          x_e <= x_e - 1;
        end
      end

      normB: begin
        if (y_m[23]) begin
          state <= MulA;
        end else begin
          y_m <= y_m << 1;
          y_e <= y_e - 1;
        end
      end
  
    
    MulA:begin
        z_s <= x_s ^ y_s;
        z_e <= x_e + y_e + 1;
        prod <= x_m * y_m * 4;
        state <= MulB;
      end

      MulB:begin
        z_m <= prod[49:26];
        guard <= prod[25];
        round_bit <= prod[24];
        sticky <= (prod[23:0] != 0);
        state <= norm1;
      end

      norm1:begin
        if (z_m[23] == 0) begin
          z_e <= z_e - 1;
          z_m <= z_m << 1;
          z_m[0] <= guard;
          guard <= round_bit;
          round_bit <= 0;
        end else begin
          state <= norm2;
        end
      end

      norm2:begin
        if ($signed(z_e) < -126) begin
          z_e <= z_e + 1;
          z_m <= z_m >> 1;
          guard <= z_m[0];
          round_bit <= guard;
          sticky <= sticky | round_bit;
        end else begin
          state <= round;
        end
      end

      round:begin
        if (guard && (round_bit | sticky | z_m[0])) begin
          z_m <= z_m + 1;
          if (z_m == 24'hffffff) begin
            z_e <=z_e + 1;
          end
        end
        state <= pack;
      end

      pack:begin
        z[22 : 0] <= z_m[22:0];
        z[30 : 23] <= z_e[7:0] + 127;
        z[31] <= z_s;
        if ($signed(z_e) == -126 && z_m[23] == 0) begin
          z[30 : 23] <= 0;
        end
        //Case: if Overflow, return inf
        if ($signed(z_e) > 127) begin
          z[22 : 0] <= 0;
          z[30 : 23] <= 255;
          z[31] <= z_s;
        end
        state <= putz;
      end

      putz:
      begin
        s_outprod_stb <= 1;
        s_out_prod <= z;
        if (s_outprod_stb && out_prod_ack) begin
          s_outprod_stb <= 0;
          state <= get_A;
        end
      end

    endcase

    if (~reset_n) begin
      state <= get_A;
      s_in_a_ack <= 0;
      s_in_b_ack <= 0;
      s_outprod_stb <= 0;
    end

  end

// code fixed  
  assign in_A_ack = s_in_a_ack;
  assign in_B_ack = s_in_b_ack;
  assign output_prod_stb = s_outprod_stb;
  assign output_prod = s_out_prod;
  

endmodule