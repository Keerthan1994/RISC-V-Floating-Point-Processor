module find_first_1 (in, out);

parameter IN_WIDTH = 27;
localparam OUT_WIDTH = $clog2(IN_WIDTH)+1;          // FIXME: Possible remove the +1 to make port width match

input [IN_WIDTH-1:0]in;
output [OUT_WIDTH-1:0]out;

wire [OUT_WIDTH-1:0]out_stage[0:IN_WIDTH];
assign out_stage[0] = ~0; // desired default output if no bits set
generate genvar i;
    for(i=0; i<IN_WIDTH; i=i+1)
        assign out_stage[i+1] = in[i] ? i : out_stage[i]; 
endgenerate
assign out = out_stage[IN_WIDTH];

endmodule