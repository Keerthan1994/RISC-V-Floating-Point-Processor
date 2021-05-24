module find_first_1 #(
    parameter OUT_WIDTH = 4, // How many bits needed to represent the index plus 1
    parameter IN_WIDTH = 1<<(OUT_WIDTH-1) // Represents the total number of bits
) (
    input [IN_WIDTH-1:0]in,
    output [OUT_WIDTH-1:0]out
);

wire [OUT_WIDTH-1:0]out_stage[0:IN_WIDTH];
assign out_stage[0] = ~0; // desired default output if no bits set
generate genvar i;
    for(i=0; i<IN_WIDTH; i=i+1)
        assign out_stage[i+1] = in[i] ? i : out_stage[i]; 
endgenerate
assign out = out_stage[IN_WIDTH];

endmodule


module top();

logic [7:0] in;
logic [3:0] out;

highbit hb0 (
    .in(in),
    .out(out)
);


initial begin
    $monitor("In: %0b, Out Index: %d.", in, out);
    #10;
    in = 8'b0100_0000;
    #10;
    in = 8'b0001_0000;
    #10;
    in = 8'b0000_0000;
    #10;
    $finish;
end


endmodule