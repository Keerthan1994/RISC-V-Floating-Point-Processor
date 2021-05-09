module FullSubtractorTb;
logic A,B,BI;
wire BO,D;

FullSubtractor F(D,BO,A,B,BI);
initial begin

A=0;B=0;BI=0;

#1 $display("A=%d, B=%d, BI=%d, D=%d, BO=%d", A,B,BI,D,BO);A=0;B=0;BI=1;
#2 $display("A=%d, B=%d, BI=%d, D=%d, BO=%d", A,B,BI,D,BO);A=0;B=1;BI=0;
#3 $display("A=%d, B=%d, BI=%d, D=%d, BO=%d", A,B,BI,D,BO);A=0;B=1;BI=1;

#4 $display("A=%d, B=%d, BI=%d, D=%d, BO=%d", A,B,BI,D,BO);A=1;B=0;BI=0;
#5 $display("A=%d, B=%d, BI=%d, D=%d, BO=%d", A,B,BI,D,BO);A=1;B=0;BI=1;
#6 $display("A=%d, B=%d, BI=%d, D=%d, BO=%d", A,B,BI,D,BO);A=1;B=1;BI=0;
#7 $display("A=%d, B=%d, BI=%d, D=%d, BO=%d", A,B,BI,D,BO);A=1;B=1;BI=1;
#8 $display("A=%d, B=%d, BI=%d, D=%d, BO=%d", A,B,BI,D,BO);

end
endmodule