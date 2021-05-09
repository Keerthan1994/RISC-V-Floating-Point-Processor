module Nbit_FullAdderTb;
parameter N=8;
logic [N-1:0] A,B,BI;
logic BO;
logic [N-1:0] D;

Nbit_FullAdder #(N) F(D,BO,A,B,BI);
initial begin

A=4;B=10;BI=0;

#10 $display("A=%d, B=%d, BI=%d, D=%d, BO=%d", A,B,BI,D,BO);A=10;B=4;BI=1;
#20 $display("A=%d, B=%d, BI=%d, D=%d, BO=%d", A,B,BI,D,BO);A=0;B=16;BI=0;
#3 $display("A=%d, B=%d, BI=%d, D=%d, BO=%d", A,B,BI,D,BO);A=50;B=17;BI=1;

#4 $display("A=%d, B=%d, BI=%d, D=%d, BO=%d", A,B,BI,D,BO);A=189;B=20;BI=0;
#5 $display("A=%d, B=%d, BI=%d, D=%d, BO=%d", A,B,BI,D,BO);A=1;B=450;BI=1;
#6 $display("A=%d, B=%d, BI=%d, D=%d, BO=%d", A,B,BI,D,BO);A=180;B=2001;BI=0;
#7 $display("A=%d, B=%d, BI=%d, D=%d, BO=%d", A,B,BI,D,BO);A=1;B=1;BI=1;
#8 $display("A=%d, B=%d, BI=%d, D=%d, BO=%d", A,B,BI,D,BO);

end
endmodule