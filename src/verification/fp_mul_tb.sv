`timescale 1ns/1ns
class transaction;
  rand bit[22:0] mantissa_A;
  rand bit[7:0] exponent_A;
  rand bit sign_A;
  
  rand bit[22:0] mantissa_B;
  rand bit[7:0] exponent_B;
  rand bit sign_B;
  
  constraint mant{
  mantissa_A != 0;
  mantissa_B != 0;  
  }
  
  constraint expo{
  exponent_A != 0;
  exponent_B != 0;
  }
  
  constraint mantis{
  mantissa_A != 7'b1;
  mantissa_B != 7'b1;
  }
  
endclass


module top;
  
  
  bit clk ;
  bit reset_n;
  
  logic [31:0] in_A ;
  logic strb_A;
  logic in_A_ack;
  
  logic [31:0] in_B ;
  logic strb_B;
  logic in_B_ack;
  
  logic [31:0] output_prod;
  logic output_prod_stb;
  logic out_prod_ack;
  
  
  fp_multiplier dut(in_A,
  in_B,
  strb_A,
  strb_B,
  out_prod_ack,
  clk,
  reset_n,
  output_prod,
  output_prod_stb,
  in_A_ack,
  in_B_ack);
  
  initial clk = 1'b0;
  always #10 clk = ~clk;
  
  //fixed code here
  initial begin
  reset_n = 1'b0;
  #100 reset_n = ~reset_n;
  end

  initial begin 
    
    $dumpfile("dump.vcd"); 
    $dumpvars;
    
  end
  
  initial begin 
   
    transaction tx;
    tx = new();
    
    repeat(100) begin
      assert(tx.randomize());
      repeat(1) begin 
       
        strb_A = 1'b1;
        strb_B = 1'b1;
        #10 out_prod_ack = 1'b1;
        in_A= {tx.sign_A,tx.mantissa_A,tx.exponent_A};
        in_B= {tx.sign_B,tx.mantissa_B,tx.exponent_B};
        @(posedge clk);
        
        strb_A = 1'b0;
        strb_B = 1'b0;
        #10 out_prod_ack = 1'b0;
        @(posedge clk);      
      end 
    end
    #100 $finish; 
  end
  
       
   
endmodule
