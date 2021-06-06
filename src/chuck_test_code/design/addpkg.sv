package addpkg;

parameter SIG_BITS = 23;
parameter EXP_BITS = 8;
//////////////////////
// Enumerated Types //
//////////////////////

// Special Cases For Input Operands
typedef enum logic [2:0] {
    NO_ERR, ZERO_ERR, ZERO_OP_ERR, NAN_ERR, INF_ERR
} i_err_t;

// Error Codes
typedef enum logic [2:0] {
    NONE, INVALID, DIVBYZERO, OVERFLOW, UNDERFLOW, INEXACT
} o_err_t;

typedef enum logic [2:0] {
    REG, NAN, INF, ZERO, DENORM, MAX, NORMMIN, DENORMMIN
} fp_case_t;

////////////////////////
// Structs and Unions //
////////////////////////

// IEEE 754 Single Precision Floating Point Format
typedef struct packed {
    logic sign;
    logic [EXP_BITS-1:0] exponent;
    logic [SIG_BITS-1:0] significand;
} ieee754_sp_t;                 // Breaks the 32-bit short real into bits

// Generic floating point type to use for unpacking
typedef union {
    logic [EXP_BITS+SIG_BITS:0] bits;          // Shortreal (32 bit) Float value
    ieee754_sp_t unpkg;      // Single Precision Floating Point Unpacked
} fp_t;

/////////////////////////
// Classes and Objects //
/////////////////////////

class FloatingPoint;
// Using this class:
// 1. Create FloatingPoint Objects for OP1, OP2, and OUT and EXP.
// 2. Use generateNew(fp_case_t) to generate a new randomized value for OP1, and OP2 of specified type.
// 2a. Use OP1.setSign(sign) and OP2.setSign(sign) to set the appropriate signs
// 3. Use EXP.setSR(OP1.getSR + OP2.getSR) and feed it the shortreal result from SV.
// 4. Feed the machine OP1.sign, OP1.exponent, OP1.significand, etc. for OP2.
// 5. Use OUT.setBits(machine_output) and feed it the machine output to set the OUT value.
// 6. Use OUT.equals(EXP) to see if they are the same!

    fp_t fp;
    bit sign;
    rand bit [EXP_BITS-1:0] exponent;
    rand bit [SIG_BITS-1:0] significand;
    fp_case_t op_case;

    // Randomization constraints
    constraint c_fp {
        if (op_case == NAN) {
            exponent == {EXP_BITS{1'b1}};
            significand > 1;
        } else if (op_case == INF) {
            exponent == {EXP_BITS{1'b1}};
            significand == 'b0;
        } else if (op_case == ZERO) {
            exponent == 'b0;
            significand == 'b0;
        } else if (op_case == DENORM) {
            exponent == 'b0;
            significand > 'b1;
        } else if (op_case == MAX) {
            exponent == {EXP_BITS{1'b1}}-1;
            significand == {SIG_BITS{1'b1}};
        } else if (op_case == NORMMIN) {
            exponent == 'b1;
            significand == 'b0;
        } else if (op_case == DENORMMIN) {
            exponent == 'b0;
            significand == 'b1;
        } else {        // Regular Case
            exponent > 'b0;
            exponent < {EXP_BITS{1'b1}};
        }
    }

    // -- CLASS METHODS --
    // Overriding new function (nothing needed atm)
    function new();
    endfunction

    // Sets op_case and randomizes accordingly
    function void generateNew(fp_case_t op_case);
        this.op_case = op_case;
        assert(this.randomize())
        else $fatal(0, "FloatingPoint::generateNew - randomize failed");
        if (op_case !== this.op_case) $error("FloatingPoint::generateNew - Generated FP type %0s does not match specified type %0s.", this.op_case.name(), op_case.name());
    endfunction

    // After randomization, update the fp_t, and type
    function void post_randomize();
        this.updateFp();
        this.updateType();
    endfunction

    // Checks if one FloatingPoint Object is the Same as this one.
    function bit equals(FloatingPoint obj);
        if (obj.op_case != this.op_case) return 0;
        if (this.op_case == NAN) return 1;
        else if (obj.sign == this.sign && obj.exponent == this.exponent && obj.significand == this.significand) return 1;      // I don't know how closely the values will match with SV
        else return 0;
    endfunction

    // Getters and Setters
    function void setFp (fp_t val);
        this.fp = val;
        this.updateFields();
        this.updateType();
    endfunction

    // Set the fp value given a bit vector
    function void setBits (logic [EXP_BITS+SIG_BITS:0] bits);
        this.fp.bits = bits;
        this.updateFields();
        this.updateType();
    endfunction

    function void setSign (bit sign);
        this.sign = sign;
        this.updateFp();
    endfunction

    function void setExponent (bit [EXP_BITS-1:0] exponent);
        this.exponent = exponent;
        this.updateFp();
        this.updateType();
    endfunction

    function void setSignificand (bit [SIG_BITS-1:0] significand);
        this.significand = significand;
        this.updateFp();
        this.updateType();
    endfunction

    function void setSR (shortreal val);
        this.fp.bits = $shortrealtobits(val);
        this.updateFields();
        this.updateType();
    endfunction

    function shortreal getSR ();
        return $bitstoshortreal(this.fp.bits);
    endfunction

    // Updating Functions
    function void updateType();
        if (this.checkIsNaN()) op_case = NAN;
        else if (this.checkIsInf()) op_case = INF;
        else if (this.checkIsZero()) op_case = ZERO;
        else if (this.checkIsDenormMin()) op_case = DENORMMIN;
        else if (this.checkIsNormMin()) op_case = NORMMIN;
        else if (this.checkIsMax()) op_case = MAX;
        else if (this.checkIsDenorm()) op_case = DENORM;
        else op_case = REG;
    endfunction

    function void updateFields();                   // Should be called anytime the fp is updated manually
        this.sign = fp.unpkg.sign;
        this.exponent = fp.unpkg.exponent;
        this.significand = fp.unpkg.significand;
    endfunction

    function void updateFp();                       // Should be called anytime a field is updated manually
        this.fp.unpkg.sign = sign;
        this.fp.unpkg.exponent = exponent;
        this.fp.unpkg.significand = significand;
    endfunction

    // Check Type Functions
    function bit checkIsNaN ();
        if (exponent == {EXP_BITS{1'b1}} && significand != 0) return 1;
        else return 0;
    endfunction

    function bit checkIsInf ();
        if (exponent == {EXP_BITS{1'b1}} && significand == 0) return 1;
        else return 0;
    endfunction

    function bit checkIsSignedNaN (bit sign);
        if (sign == this.sign && exponent == {EXP_BITS{1'b1}} && significand != 0) return 1;
        else return 0;
    endfunction

    function bit checkIsSignedInf (bit sign);
        if (sign == this.sign && exponent == 8'hFF && significand == 0) return 1;
        else return 0;
    endfunction

    function bit checkIsDenorm ();
        if (exponent == 0 && significand != 0) return 1;
        else return 0;
    endfunction

    function bit checkIsZero ();
        if (exponent == 0 && significand == 0) return 1;
        else return 0;
    endfunction

    function bit checkIsMax ();
        if (exponent == {EXP_BITS{1'b1}}-1 && significand == {SIG_BITS{1'b1}}) return 1;
        else return 0;
    endfunction

    function bit checkIsNormMin ();
        if (exponent == 'b1 && significand == 0) return 1;
        else return 0;
    endfunction

    function bit checkIsDenormMin ();
        if (exponent == 'b0 && significand == 'b1) return 1;
        else return 0;
    endfunction

    // Display Functions
    function string bitsToString();
        return $sformatf("%1b %8b %23b", this.sign, this.exponent, this.significand);
    endfunction

endclass

//////////////////////////////////
// External Functions and Tasks //
//////////////////////////////////

// Note: With the implementation of the class object for FloatingPoint and its 
// associated methods, many of the functions below have been phased out. We are keeping
// them here for posterity, and also for usefulness in case we need to do something
// specific.

// -- FPU Testing Functions and Tasks --

// MAIN TEST TASK
//  Foreach op1 = fp_case_t: 
//      foreach op2 = fp_case_t: 
//          for {opcode, op1_sign, op2_sign} = 0-7: 
//              for 0-N tests: 
//                  generate op1, op2, and test output with expected. 
//                  Check Error Code.



// task automatic singleTestCase (
//     ref FloatingPoint op1, op2, exp, out,                                             // Declared FloatingPoint Objects
//         logic opcode, sign1, sign2, logic [7:0] exp1, exp2, logic [22:0] sig1, sig2,        // Ports linked to add/sub module
//         logic [31:0] fp_out, o_err_t err_o,
//     input fp_case_t op1_case, op2_case, bit addsub_op, op1_sign, op2_sign                    // Non-Pass-by-Ref Variables
//     );
//     o_err_t exp_err;

//     // Setup Operands and Calculate Expected Value
//     op1.generateNew(op1_case);
//     op2.generateNew(op2_case);
//     op1.setSign(op1_sign);
//     op2.setSign(op2_sign);
//     unique case (addsub_op)
//         1'b0: exp.setSR(op1.getSR + op2.getSR);
//         1'b1: exp.setSR(op1.getSR - op2.getSR);
//     endcase
//     exp_err = expectedErrorCode(exp);
//     sign1 = op1.sign;
//     sign2 = op2.sign;
//     exp1 = op1.exponent;
//     exp2 = op2.exponent;
//     sig1 = op1.significand;
//     sig2 = op2.significand;
//     opcode = addsub_op;

//     // DELAY HERE
//     #50;

//     out.setBits(fp_out);
//     if (!out.equals(exp)) begin
//         $display("%0t::VALUE/TYPE MISMATCH: OP1=%0e %0s. OP2=%0e %0s. OP_CODE=%0b. EXP=%0e. RES=%0e. EXP_TYPE=%0s. RES_TYPE=%0s.", $time, op1.getSR(), op1.op_case.name(), op2.getSR(), op2.op_case.name(), addsub_op, exp.getSR(), out.getSR(), exp.op_case.name(), out.op_case.name());
//         $display("RES_BITS=%0s.", out.bitsToString());
//         // $display("%1b %8b %27b Carry: %1b", ast0.sign_r, ast0.exp_f, sig_f, ast0.carry5);
//     end
//     if (err_o !== exp_err) begin
//         $display("%0t::ERROR CODE MISMATCH: OP1=%0e. OP2=%0e. OP_CODE=%0b. EXP_ERR=%0s. RES_ERR=%0s.", $time(), op1.getSR(), op2.getSR(), addsub_op, exp_err.name(), err_o.name());
//     end

//     `ifdef DEBUG
//     $display("%0t: OP1=%0e. OP2=%0e. OP_CODE=%0b. EXP=%0e. RES=%0e. EXP_TYPE=%0s. RES_TYPE=%0s. EXP_ERR=%0s. RES_ERR=%0s.", $time, op1.getSR(), op2.getSR(), addsub_op, exp.getSR(), out.getSR(), exp.op_case.name(), out.op_case.name(), exp_err.name(), err_o.name());
//     `endif

// endtask

    // op1.generateNew(ZERO);
    // op2.generateNew(INF);

    // $display("Op1 Value: %0e. Op2 Value: %0e. Expected Value: %0e.", op1.getSR(), op2.getSR(), exp.getSR());

    // #10;
    // sign1 = op1.sign;
    // sign2 = op2.sign;
    // exp1 = op1.exponent;
    // exp2 = op2.exponent;
    // sig1 = op1.significand;
    // sig2 = op2.significand;
    // opcode = 1'b1;

    // #20;
    // out.setBits(fp_out);
    // $display("Resultant Value: %0e. Equal?: %0b", out.getSR(), out.equals(exp));

// Tasks/Functions we need:
// - Generates the N set of operands for each case (64) in the Op Combination Table. Sets the expected result type. 
//      Sets the expected error codes. Then calls the function to run through the sign logic table 
//      for each set of generated operands
// - Takes two generated operands and manipulates the signs and opcodes to test every case (8) in the
//      sign logic table.
// - Compares the results of the FPU operation ensuring that the result of is of the right type
//      and if not a special case, that the result matches the expected result (self-checking).
//      Should also check the resultant error codes. Will need access to complement signal.

// --SV Constructs--
// {{CLASSES}}
// OBJECT: FloatingPoint Object
// DATA: Sign, Exponent, Significand, fp_t, fp_case_t
// METHODS: Unpack Shortreal, Pack Shortreal, Given a special case type construct the fp_t, check the type,

function o_err_t expectedErrorCode (FloatingPoint exp);
    unique case (exp.op_case)
        REG: return NONE;
        NAN: return INVALID;
        INF: return OVERFLOW;
        ZERO: return NONE;
        DENORM: return UNDERFLOW;
        MAX: return NONE;
        NORMMIN: return NONE;
        DENORMMIN: return UNDERFLOW;
    endcase
endfunction

// -- fp_t packing and unpacking functions --

// Function which takes a shortreal and converts it into a fp_t type to work with in the FPU
function fp_t fpUnpack (shortreal val);
    fp_t fp;
    fp.bits = $shortrealtobits(val);
    return fp;
endfunction

// Function which takes a fp_t number and converts it to shortreal for printing/display.
function shortreal fpPack (fp_t val);
    shortreal fp;
    fp = $bitstoshortreal(val.bits);
    return fp;
endfunction

// -- Special Case Check Functions --

// Checks if a fp_t is NaN
function bit checkIsNaN (fp_t fp);
    if (fp.unpkg.exponent == {EXP_BITS{1'b1}} && fp.unpkg.significand != 0) return 1;
    else return 0;
endfunction

// Checks if a fp_t is INF
function bit checkIsInf (fp_t fp);
    if (fp.unpkg.exponent == {EXP_BITS{1'b1}} && fp.unpkg.significand == 0) return 1;
    else return 0;
endfunction

// Checks if fp_t is NaN with added sign check
function bit checkIsSignedNaN (fp_t fp, bit sign);
    if (fp.unpkg.sign == sign && fp.unpkg.exponent == {EXP_BITS{1'b1}} && fp.unpkg.significand != 0) return 1;
    else return 0;
endfunction

// Checks if fp_t is INF with added sign check
function bit checkIsSignedInf (fp_t fp, bit sign);
    if (fp.unpkg.sign == sign && fp.unpkg.exponent == {EXP_BITS{1'b1}} && fp.unpkg.significand == 0) return 1;
    else return 0;
endfunction

// Checks if fp_t is denormalized value
function bit checkIsDenorm (fp_t fp);
    if (fp.unpkg.exponent == 0 && fp.unpkg.significand != 0) return 1;
    else return 0;
endfunction

// Checks if fp_t is Zero valued
function checkIsZero (fp_t fp);
    if (fp.unpkg.exponent == 0 && fp.unpkg.significand == 0) return 1;
    else return 0;
endfunction

// Checks if fp_t is the max FP value
function checkIsMax (fp_t fp);
    if (fp.unpkg.exponent == {EXP_BITS{1'b1}}-1 && fp.unpkg.significand == {SIG_BITS{1'b1}}) return 1;
    else return 0;
endfunction

// Checks if fp_t is the min normalized FP value
function checkIsNormMin (fp_t fp);
    if (fp.unpkg.exponent == 'b1 && fp.unpkg.significand == 0) return 1;
    else return 0;
endfunction

// Checks if fp_t is the min normalized FP value
function checkIsDenormMin (fp_t fp);
    if (fp.unpkg.exponent == 'b0 && fp.unpkg.significand == 'b1) return 1;
    else return 0;
endfunction

// --Operand Generation Functions--

// Function that returns a NaN fp_t of a particular sign
function fp_t createNaN (bit sign);
    fp_t fp;
    fp.unpkg.sign = sign;
    fp.unpkg.exponent = '1;
    fp.unpkg.significand = '1;
    return fp;
endfunction

// Function that returns a INF fp_t of a particular sign
function fp_t createInf (bit sign);
    fp_t fp;
    fp.unpkg.sign = sign;
    fp.unpkg.exponent = '1;
    fp.unpkg.significand = '0;
    return fp;
endfunction

// Function that generates a random fp_t value of a particular sign
function fp_t createRandReg (bit sign);
    fp_t fp;
    fp.unpkg.sign = sign;
    // Bounded random for exponent and sig
    fp.unpkg.exponent = $urandom_range(254, 1);
    fp.unpkg.significand = $urandom();
    return fp;
endfunction

function fp_t createRandDenorm (bit sign);
    fp_t fp;
    fp.unpkg.sign = sign;
    fp.unpkg.exponent = '0;
    // Bounded random for significand
    fp.unpkg.significand = $urandom();
    if (fp.unpkg.significand == 0) fp.unpkg.significand += 1'b1;
    return fp;
endfunction

function fp_t createMax(bit sign);
    fp_t fp;
    fp.unpkg.sign = sign;
    fp.unpkg.exponent = {EXP_BITS{1'b1}}-1;
    fp.unpkg.significand = {SIG_BITS{1'b1}};
    return fp;
endfunction

function fp_t createNormMin(bit sign);
    fp_t fp;
    fp.unpkg.sign = sign;
    fp.unpkg.exponent = 'b1;
    fp.unpkg.significand = 'b0;
    return fp;
endfunction

function fp_t createDenormMin(bit sign);
    fp_t fp;
    fp.unpkg.sign = sign;
    fp.unpkg.exponent = 'b0;
    fp.unpkg.significand = 'b1;
    return fp;
endfunction

// Function that changes the sign bit of a given fp_t to the
// specified sign and returns the fp_t.
function fp_t changeSign (fp_t val, bit sign);
    val.unpkg.sign = sign;
    return val;
endfunction

// -- Functions that Test the Other Functions --

function void FpUnpackTest (shortreal val);
    fp_t num;
    num = fpUnpack(val);
    // Print out the bits that make up this value:
    $display("Val = %f", val);
    $display("Bits = %b", num.bits);
    $display("sign bit = %b, exponent = %b, significand = %b.", num.unpkg.sign, num.unpkg.exponent, num.unpkg.significand);
endfunction

function void InfNaNTests ();
    fp_t num;
    shortreal sr;
    num = createNaN(0);
    sr = fpPack(num);
    $display("Result: %0f.", sr);
    $display("Is NaN? %b.", checkIsNaN(num));
    $display("Is Inf? %b.", checkIsInf(num));
    
    num = createInf(0);
    sr = fpPack(num);
    $display("Result: %0f.", sr);
    $display("Is NaN? %b.", checkIsNaN(num));
    $display("Is Inf? %b.", checkIsInf(num));
endfunction

endpackage