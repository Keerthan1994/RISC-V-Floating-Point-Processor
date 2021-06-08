import fp_pkg::*;

parameter SIG_BITS = 23;
parameter EXP_BITS = 8;
module top();

parameter NTESTS = 1;

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
opcode_t opc;           // opcode
o_err_t err_o_div;

// Verification Signals
FloatingPoint op1, op2, out, exp;

fp_case_t op1_case, op2_case;
logic [3:0] sign_tc;    // {opcode, op1_sign, op2_sign}
bit err;

initial 
    forever #10 clk = ~clk;

// Instantiate ADD/SUB Module
add_sub_top ast0 (.*);
fdiv_newton fdiv0 (.*, .err_o(err_o_div));

initial begin
    op1 = new();
    op2 = new();
    out = new();
    exp = new();

    op1_case = op1_case.first;
    op2_case = op2_case.first;
    sign_tc = '0;

// FULL ADD/SUB TEST
// FIXME: Need to implement multiply and divide in this later.
// and need to change opcode handling.
// do begin
//     do begin
//         for (sign_tc = 0; sign_tc < 8; sign_tc++) begin
//             for (int i = 0; i < NTESTS; i++) begin
//                 generateTestCase(op1, op2, exp, op1_case, op2_case, sign_tc[1], sign_tc[0], opcode_t'(sign_tc[2]));
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

// DIV Test

//clk
clk = 1'b0;
// assert reset
rstn = 1'b0;
#10 rstn = 1'b1;
ena = 1'b0;
fdiv = 1'b0;
rm = 2'b0;
sign_tc = 0;
opc = DIV;

do begin
    do begin
        for (sign_tc = 0; sign_tc < 4; sign_tc++) begin
            for (int i = 0; i < NTESTS; i++) begin
                if (opc == DIV) begin
                    ena = 1'b1;
                    fdiv = 1'b1;
                end else begin
                    ena = 1'b0;
                    fdiv = 1'b0;
                end
                generateTestCase(op1, op2, exp, op1_case, op2_case, sign_tc[1], sign_tc[0], opc);
                sign1 = op1.getSign();
                sign2 = op2.getSign();
                exp1 = op1.getExponent();
                exp2 = op2.getExponent();
                sig1 = op1.getSignificand();
                sig2 = op2.getSignificand();
                wait(!busy);
                a = {sign1, exp1, sig1};
                b = {sign2, exp2, sig2};

                #300;
                wait(!busy);
                out.setBits(s);
                checkResults(op1, op2, out, exp, opc, err);
                if (err) begin 
                    err_count += 1;
                    $display("EXP: %0b", exp.bitsToString);
                    $display("OUT: %0b", out.bitsToString);
                end
                checkErrorCode(exp, err_o);
                test_count += 1;
                // singleTestCase(op1, op2, exp, out, opcode, sign1, sign2, exp1, exp2, sig1, sig2, fp_out, err_o, op1_case, op2_case, sign_tc[2], sign_tc[1], sign_tc[0]);
            end
        end
        op2_case = op2_case.next;
    end while(op2_case != op2_case.first);
    op1_case = op1_case.next;
end while(op1_case != op1_case.first);


    $finish();
end

final begin
    $display("%0d Errors Out of %0d Tests.", err_count, test_count);
end

endmodule
