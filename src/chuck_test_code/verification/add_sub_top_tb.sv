import fp_pkg::*;

parameter SIG_BITS = 23;
parameter EXP_BITS = 8;
module top();

parameter NTESTS = 1000;

// shortreal op1, op2, out;
shortreal out_sr;
// fp_t op1, op2, out;

// ADD/SUB Signals
logic sign1, sign2;
logic [EXP_BITS-1:0] exp1, exp2;
logic [SIG_BITS-1:0] sig1, sig2;
logic opcode;
logic [EXP_BITS+SIG_BITS:0] fp_out;
// logic [2:0] err_o;
o_err_t err_o;
int err_count, test_count;

// DIV Signals
logic [31:0] a, b;      // 32 bit operands
logic fdiv;             // enable for division operation
logic [1:0] rm;         // rounding mode -- default: 1'b0
logic ena;              // enable for whole module
logic clk;              // clock
logic rstn;             // reset_n
logic [31:0] s;         // result/output
logic busy;             // busy processing (1): won't take new inputs. (0): will take new inputs
logic stall;            // same as above
logic [4:0] count;      // Total number of cycles to complete last operation
logic [25:0] reg_x;     // Partial Product Output for Debugging
o_err_t err_o_div;

// MUL Signals
logic reset_n;              // Reset active low signal
logic [31:0] in_A ;         // 32 Bit FP operand A.
logic strb_A;               // Asserted to module when input A is valid
logic in_A_ack;             // Asserted by module when input A is received
logic [31:0] in_B ;         // 32 Bit FP operan
logic strb_B;               // Asserted to module when input A is valid
logic in_B_ack;             // Asserted by module when input A is received
logic output_prod;          // Output produce
logic output_prod_stb;      // Asserted when output is valid
logic out_prod_ack;         // probably not required.

// Verification Signals
FloatingPoint op1, op2, out, exp;
opcode_t opc;           // opcode

fp_case_t op1_case, op2_case;
logic [3:0] sign_tc;    // {opcode, op1_sign, op2_sign}
bit err;

initial 
    forever #10 clk = ~clk;

// Instantiate FP Modules
add_sub_top ast0 (.*);
fdiv_newton fdiv0 (.*, .err_o(err_o_div));
fp_multiplier fmul0 (.*);

initial begin
    op1 = new();
    op2 = new();
    out = new();
    exp = new();

    op1_case = op1_case.first;
    op2_case = op2_case.first;
    sign_tc = '0;

///////////////////////
// FULL ADD/SUB TEST //
///////////////////////

// FIXME: Need to implement multiply and divide in this later.
// and need to change opcode handling.

// Corner Case Testing
// do begin
//     do begin
//         for (sign_tc = 0; sign_tc < 8; sign_tc++) begin
//             for (int i = 0; i < NTESTS; i++) begin
//                 generateCornerCase(op1, op2, exp, op1_case, op2_case, sign_tc[1], sign_tc[0], opcode_t'(sign_tc[2]));
//                 opcode = sign_tc[2];
//                 sign1 = op1.getSign();
//                 sign2 = op2.getSign();
//                 exp1 = op1.getExponent();
//                 exp2 = op2.getExponent();
//                 sig1 = op1.getSignificand();
//                 sig2 = op2.getSignificand();

//                 #150;
//                 out.setBits(fp_out);
//                 checkResults(op1, op2, out, exp, opcode_t'(sign_tc[2]), err);
//                 if (err) begin 
//                     err_count += 1;
//                     $display("EXP: %0b", exp.bitsToString);
//                     $display("OUT: %0b", out.bitsToString);
//                 end
//                 checkErrorCode(exp, err_o);
//                 test_count += 1;
//                 // singleTestCase(op1, op2, exp, out, opcode, sign1, sign2, exp1, exp2, sig1, sig2, fp_out, err_o, op1_case, op2_case, sign_tc[2], sign_tc[1], sign_tc[0]);
//             end
//         end
//         op2_case = op2_case.next;
//     end while(op2_case != op2_case.first);
//     op1_case = op1_case.next;
// end while(op1_case != op1_case.first);


// for (int i = 0; i < (NTESTS * 512); i++) begin
//     opc = opcode_t'($urandom_range(1,0));
//     generateRandCase(op1, op2, exp, opc);
//     opcode = bit'(opc);
//     sign1 = op1.getSign();
//     sign2 = op2.getSign();
//     exp1 = op1.getExponent();
//     exp2 = op2.getExponent();
//     sig1 = op1.getSignificand();
//     sig2 = op2.getSignificand();

//     #150;
//     out.setBits(fp_out);
//     checkResults(op1, op2, out, exp, opc, err);
//     if (err) begin 
//         err_count += 1;
//         $display("EXP: %0b", exp.bitsToString);
//         $display("OUT: %0b", out.bitsToString);
//     end
//     checkErrorCode(exp, err_o);
//     test_count += 1;
// end


//////////////////////////////////
// DIV Test -- Now Generic Test //
//////////////////////////////////

    clk = 1'b0;
    // assert reset
    rstn = 1'b0;
    #10 rstn = 1'b1;
    ena = 1'b0;
    fdiv = 1'b0;
    rm = 2'b0;
    ena = 1'b1;
    fdiv = 1'b1;
    sign_tc = 0;
    opc = ADD;

    do begin
        do begin
            for (sign_tc = 0; sign_tc < 4; sign_tc++) begin
                for (int i = 0; i < NTESTS; i++) begin
                    generateCornerCase(op1, op2, exp, op1_case, op2_case, sign_tc[1], sign_tc[0], opc);
                    
                    // Add/Sub Inputs
                    opcode = bit'(opc);
                    sign1 = op1.getSign();
                    sign2 = op2.getSign();
                    exp1 = op1.getExponent();
                    exp2 = op2.getExponent();
                    sig1 = op1.getSignificand();
                    sig2 = op2.getSignificand();

                    // Mult/Div Specific Input Handling
                    if (opc == DIV) begin
                        wait(!busy);
                        a = {sign1, exp1, sig1};    // Div Input
                        b = {sign2, exp2, sig2};    // Div Input
                    end else if (opc == MUL) begin
                        in_A = {sign1, exp1, sig1};                   // Mult Input
                        in_B = {sign2, exp2, sig2};                   // Mult Input
                        repeat (1) @(negedge clk);
                        strb_A = 1'b1;
                        strb_B = 1'b1;
                        repeat (1) @(negedge clk);
                        strb_A = 1'b0;
                        strb_B = 1'b0;
                    end


                    // Op Code Specific Waits and Outputs
                    case (opc)
                        ADD: begin 
                            #150;
                            out.setBits(fp_out);
                        end
                        SUB: begin
                            #50;
                            out.setBits(fp_out);
                        end
                        MUL: begin 
                            out.setBits(output_prod);
                        end
                        DIV: begin
                            #300;
                            wait(!busy);
                            out.setBits(s);
                        end
                    endcase
                    checkResults(op1, op2, out, exp, opc, err);
                    if (err) begin 
                        err_count += 1;
                        $display("EXP: %0b", exp.bitsToString);
                        $display("OUT: %0b", out.bitsToString);
                    end
                    checkErrorCode(exp, err_o);
                    test_count += 1;
                end
            end
            op2_case = op2_case.next;
        end while(op2_case != op2_case.first);
        op1_case = op1_case.next;
    end while(op1_case != op1_case.first);


//////////////
// MUL Test //
//////////////

    // clk = 1'b0;
    // // assert reset
    // reset_n = 1'b0;
    // #10 reset_n = 1'b1;
    // opc = MUL;


    // do begin
    //     do begin
    //         for (sign_tc = 0; sign_tc < 4; sign_tc++) begin
    //             for (int i = 0; i < NTESTS; i++) begin
    //                 $display("Generating Test Case");
    //                 generateCornerCase(op1, op2, exp, op1_case, op2_case, sign_tc[1], sign_tc[0], opc);
    //                 sign1 = op1.getSign();
    //                 sign2 = op2.getSign();
    //                 exp1 = op1.getExponent();
    //                 exp2 = op2.getExponent();
    //                 sig1 = op1.getSignificand();
    //                 sig2 = op2.getSignificand();
    //                 in_A = {sign1, exp1, sig1};
    //                 in_B = {sign2, exp2, sig2};
    //                 #1;
    //                 $display("Setting Strobe Signals");
    //                 strb_A = 1'b1;
    //                 strb_B = 1'b1;
    //                 repeat (1) @(negedge clk);
    //                 strb_A = 1'b0;
    //                 strb_B = 1'b0;

    //                 #300;
    //                 $display("Waiting for output strobe");
    //                 wait(output_prod_stb);
    //                 $display("Finished waiting, setting out");
    //                 out.setBits(output_prod);
    //                 out_prod_ack = 1'b1;
    //                 repeat (1) @(negedge clk);
    //                 out_prod_ack = 1'b0;
    //                 $display("Checking Results");
    //                 checkResults(op1, op2, out, exp, opc, err);
    //                 if (err) begin 
    //                     err_count += 1;
    //                     $display("EXP: %0b", exp.bitsToString);
    //                     $display("OUT: %0b", out.bitsToString);
    //                 end
    //                 $display("Checking Error Code");
    //                 checkErrorCode(exp, err_o);
    //                 test_count += 1;
    //             end
    //         end
    //         op2_case = op2_case.next;
    //     end while(op2_case != op2_case.first);
    //     op1_case = op1_case.next;
    // end while(op1_case != op1_case.first);


    $finish();
end

final begin
    $display("%0d Errors Out of %0d Tests.", err_count, test_count);
end

endmodule
