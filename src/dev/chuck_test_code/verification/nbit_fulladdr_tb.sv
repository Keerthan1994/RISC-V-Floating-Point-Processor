module Nbit_FullAdderTb;
parameter N=8;
logic [N-1:0] A,B,CI;
logic CO;
logic [N-1:0] sum;
logic [N:0] precomp, postcomp;

Nbit_FullAdder #(N) F(sum,CO,A,B,CI);
initial begin

A=~4+1;B=10;CI=0;
#10;
precomp = {CO,sum};
postcomp = ~precomp + 1;
$display("A=%d, B=%d, CI=%d, sum=%d, CO=%d", $signed(A),$signed(B),CI,$signed(sum),CO);
$display("precomp: %9b. postcomp: %9b.", precomp, postcomp);

A=~10+1;B=4;CI=0;
#10;
precomp = {CO,sum};
postcomp = ~precomp + 1;
$display("A=%d, B=%d, CI=%d, sum=%d, CO=%d", $signed(A),$signed(B),CI,$signed(sum),CO);
$display("precomp: %9b. postcomp: %9b.", precomp, postcomp);

A=4;B=~10+1;CI=0;
#10;
precomp = {CO,sum};
postcomp = ~precomp + 1;
$display("A=%d, B=%d, CI=%d, sum=%d, CO=%d", $signed(A),$signed(B),CI,$signed(sum),CO);
$display("precomp: %9b. postcomp: %9b.", precomp, postcomp);

A=~4+1;B=~10+1;CI=0;
#10;
precomp = {CO,sum};
postcomp = ~precomp + 1;
$display("A=%d, B=%d, CI=%d, sum=%d, CO=%d", $signed(A),$signed(B),CI,$signed(sum),CO);
$display("precomp: %9b. postcomp: %9b.", precomp, postcomp);
// A=10;B=-4;BI=0;
// #20 $display("A=%d, B=%d, BI=%d, D=%d, BO=%d", A,B,BI,D,BO);A=0;B=16;BI=0;
// #3 $display("A=%d, B=%d, BI=%d, D=%d, BO=%d", A,B,BI,D,BO);A=50;B=17;BI=1;

// #4 $display("A=%d, B=%d, BI=%d, D=%d, BO=%d", A,B,BI,D,BO);A=189;B=20;BI=0;
// #5 $display("A=%d, B=%d, BI=%d, D=%d, BO=%d", A,B,BI,D,BO);A=1;B=450;BI=1;
// #6 $display("A=%d, B=%d, BI=%d, D=%d, BO=%d", A,B,BI,D,BO);A=180;B=2001;BI=0;
// #7 $display("A=%d, B=%d, BI=%d, D=%d, BO=%d", A,B,BI,D,BO);A=1;B=1;BI=1;
// #8 $display("A=%d, B=%d, BI=%d, D=%d, BO=%d", A,B,BI,D,BO);

end
endmodule