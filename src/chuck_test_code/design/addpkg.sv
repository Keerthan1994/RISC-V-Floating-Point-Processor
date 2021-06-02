package addpkg;

///////////////////////////////////////
// Internal and External Error Codes //
///////////////////////////////////////

// Special Cases For Input Operands
typedef enum logic [1:0] {
    NOERR, ZERO, NAN, INF
} i_err_t;

// Error Codes
typedef enum logic [2:0] {
    NONE, INVALID, DIVBYZERO, OVERFLOW, UNDERFLOW, INEXACT
} o_err_t;

////////////////////////////////////////////
// Floating Point Definitions and Methods //
////////////////////////////////////////////

// IEEE 754 Single Precision Floating Point Format
typedef struct packed {
    logic sign;
    logic [7:0] exponent;
    logic [22:0] significand;
} ieee754_sp_t;                 // Breaks the 32-bit short real into bits

// Generic floating point type to use for unpacking
typedef union {
    logic [31:0] bits;          // Shortreal (32 bit) Float value
    ieee754_sp_t unpkg;      // Single Precision Floating Point Unpacked
} fp_t;

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

//////////////////////////////////
// Special Case Check Functions //
//////////////////////////////////

// Checks if a fp_t is NaN
function bit checkIsNaN (fp_t fp);
    if (fp.unpkg.exponent == 8'hFF && fp.unpkg.significand != 0) return 1;
    else return 0;
endfunction

// Checks if a fp_t is INF
function bit checkIsInf (fp_t fp);
    if (fp.unpkg.exponent == 8'hFF && fp.unpkg.significand == 0) return 1;
    else return 0;
endfunction

// Checks if fp_t is NaN with added sign check
function bit checkIsSignedNaN (fp_t fp, bit sign);
    if (fp.unpkg.sign == sign && fp.unpkg.exponent == 8'hFF && fp.unpkg.significand != 0) return 1;
    else return 0;
endfunction

// Checks if fp_t is INF with added sign check
function bit checkIsSignedInf (fp_t fp, bit sign);
    if (fp.unpkg.sign == sign && fp.unpkg.exponent == 8'hFF && fp.unpkg.significand == 0) return 1;
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
    if (fp.unpkg.exponent == 8'b1111_1110 && fp.unpkg.significand == 23'b111_1111_1111_1111_1111_1111) return 1;
    else return 0;
endfunction

// Checks if fp_t is the min normalized FP value
function checkIsNormMin (fp_t fp);
    if (fp.unpkg.exponent == 8'b0000_0001 && fp.unpkg.significand == 0) return 1;
    else return 0;
endfunction

// Checks if fp_t is the min normalized FP value
function checkIsDenormMin (fp_t fp);
    if (fp.unpkg.exponent == 8'b0000_0000 && fp.unpkg.significand == 23'b000_0000_0000_0000_0000_0001) return 1;
    else return 0;
endfunction

//////////////////////////////////
// Operand Generation Functions //
//////////////////////////////////

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
    if (fp.unpkg.significand == 0) fp_unpkg.significand += 1'b1;
    return fp;
endfunction

function fp_t createMax(bit sign);
    fp_t fp;
    fp.unpkg.sign = sign;
    fp.unpkg.exponent = 8'b1111_1110;
    fp.unpkg.significand = 23'b111_1111_1111_1111_1111_1111;
    return fp;
endfunction

function fp_t createNormMin(bit sign);
    fp_t fp;
    fp.unpkg.sign = sign;
    fp.unpkg.exponent = 8'b0000_0001;
    fp.unpkg.significand = 23'b000_0000_0000_0000_0000_0000;
    return fp;
endfunction

function fp_t createDenormMin(bit sign);
    fp_t fp;
    fp.unpkg.sign = sign;
    fp.unpkg.exponent = 8'b0000_0000;
    fp.unpkg.significand = 23'b000_0000_0000_0000_0000_0001;
    return fp;
endfunction

// Function that changes the sign bit of a given fp_t to the
// specified sign and returns the fp_t.
function fp_t changeSign (fp_t val, bit sign);
    val.unpkg.sign = sign;
    return val;
endfunction

/////////////////////////////
// Tasks for Running Tests //
/////////////////////////////

// Task which takes two operands and applies the appropriate opcode, and sign
// for each operand.
// FIXME: Find some way to output these to the top testbench, and also need
// someway to check the result.
task automatic signLogicTest (input fp_t op1, op2);
    bit [2:0] sign_tc;      // {opcode, op1_sign, op2_sign}
    for (sign_tc = 0; sign_tc < 8; sign_tc++) begin
        opcode = sign_tc[2];
        op1 = changeSign(op1, sign_tc[1]);
        op2 = changeSign(op2, sign_tc[0]);
        #10;        // Will have some delay and will have to read the result
    end
endtask

// Tasks/Functions we need:
// - Generates the N set of operands for each case (49) in the Op Combination Table. Sets the expected result type. 
//      Sets the expected error codes. Then calls the function to run through the sign logic table 
//      for each set of generated operands
// - Takes two generated operands and manipulates the signs and opcodes to test every case (8) in the
//      sign logic table.
// - Compares the results of the FPU operation ensuring that the result of is of the right type
//      and if not a special case, that the result matches the expected result (self-checking).
//      Should also check the resultant error codes. Will need access to complement signal.


// --Testbench Flow--
// 1. Define Combo Case operand types
// 2. Generate table of 8 expected result types and error codes using sign logic table. (particularly complement logic)
// 3. Generate two operands
// 4. Populate an 8 element table with the expected result for each sign table case
// 5. Adjust the signs and opcode of the operands and pass to FPU
// 6. Delay
// 7. Store Result to an 8 element table
// 8. Repeat steps 5-7 for all sign table cases (8 times)
// 9. For each of the 8 items check that result types and error codes match expected types generated in step 2.
// 10. For each of the 8 items, if the result type is not INF or NaN, compare the values generated in step 4
// 11. Repeat steps 3-10 N times.
// 12. Move to next case, and repeat steps 1-11 for each case.

// --SV Constructs--
// Let's use a class for reg floating point object
// Maybe extend the class for denorm, max, norm-min, denorm-min, NaN, and Inf
// Base methods: 
//  - construct floating point based on shortreal. 
//  - output short real based on floating point.

// --Reference Tables--
// For each combo case (64 cases): 8 element tables -- expected result type, expected error code
// For each operand pair: 8 element tables -- expected result, actual result, actual error code

// OBJECT: Floating Point Object
// DATA: Sign, Exponent, Significand, fp_t, fp_case
// METHODS: Unpack Shortreal, Pack Shortreal, Given a special case type construct the fp_t, check the type,

// OBJECT: OP Pair Test Object
// DATA: Op1, Op2, Expected Results, Actual Results, Actual Errors, Actual Types
// METHODS: Apply 8 sign tests and store expected results and errors, Identify the type of each result

// OBJECT: Combo Case Object
// DATA: Case 1, Case 2, Expected Types, Expected Errors, Op Test Objects
// METHODS: Generate Op Pair Objects, Compare Actual Errors with Expected Errors, Compare Actual Types with Expected Types, 
//          Compare expected result with actual result (within op pair obj) if valid

typedef enum logic [2:0] {REG, NAN, INF, ZERO, DENORM, MAX, NORMMIN, DENORMMIN} fp_case;

class FloatingPoint;
// Using this class:
// 1. Create FloatingPoint Objects for OP1, OP2, and OUT and EXP.
// 2. Use generateNew(fp_case) to generate a new randomized value for OP1, and OP2 of specified type.
// 2a. Ise OP1.setSign(sign) and OP2.setSign(sign) to set the appropriate signs
// 3. Feed the machine OP1.sign, OP1.exponent, OP1.significand, etc. for OP2.
// 4. Use OUT.setFp(machine_output) and feed it the machine output to set the OUT value.
// 5. Use EXP.setSR(shortreal) and feed it the shortreal result from SV.
// 6. Use OUT.equals(EXP) to see if they are the same!
    fp_t fp;
    bit sign;
    rand bit [7:0] exponent;
    rand bit [22:0] significand;
    fp_case op_case;

    constraint c_fp {
        if (op_case == NAN) {
            exponent == 8'b1111_1111;
            significand > 1;
        } else if (op_case == INF) {
            exponent == 8'b1111_1111;
            significand == 23'b0;
        } else if (op_case == ZERO) {
            exponent == 8'b0;
            significand == 23'b0;
        } else if (op_case == DENORM) {
            exponent == 8'b0;
            significand > 23'b000_0000_0000_0000_0000_0001;
        } else if (op_case == MAX) {
            exponent == 8'b1111_1110;
            significand == 23'b111_1111_1111_1111_1111_1111;
        } else if (op_case == NORMMIN) {
            exponent == 8'b0000_0001;
            significand == 23'b0;
        } else if (op_case == DENORMMIN) {
            exponent == 8'b0;
            significand == 23'b000_0000_0000_0000_0000_0001;
        } else {        // Regular Case
            exponent > 8'b0;
            exponent < 8'b1111_1111;
        }
    }

    function new();
    endfunction

    function void generateNew(fp_case op_case);
        this.op_case = op_case;
        assert(this.randomize())
        else $fatal(0, "FloatingPoint::generateNew - randomize failed");
        if (op_case !== this.op_case) $error("FloatingPoint::generateNew - Generated FP type %0s does not match specified type %0s.", this.op_case.name(), op_case.name());
    endfunction

    function void post_randomize();
        this.updateFp();
        this.updateType();
    endfunction

    function bit equals(FloatingPoint obj);
        if (obj.op_case != this.op_case) return 0;
        if (this.op_case == NAN || this.op_case == INF) return 1;
        else if (obj.sign == this.sign && obj.exp == this.exp && obj.significand == this.signficand) return 1;      // I don't know how closely the values will match with SV
        else return 0;
    endfunction

    function void setFp (fp_t val);
        this.fp = val;
        this.updateFields();
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

    function void setSign (bit sign);
        this.sign = sign;
        this.updateFp();
    endfunction

    function void setExponent (bit [7:0] exponent);
        this.exponent = exponent;
        this.updateFp();
        this.updateType();
    endfunction

    function void setSignificand (bit [22:0] significand);
        this.significand = significand;
        this.updateFp();
        this.updateType();
    endfunction

    function bit checkIsNaN ();
        if (exponent == 8'hFF && significand != 0) return 1;
        else return 0;
    endfunction

    function bit checkIsInf ();
        if (exponent == 8'hFF && significand == 0) return 1;
        else return 0;
    endfunction

    function bit checkIsSignedNaN (bit sign);
        if (sign == this.sign && exponent == 8'hFF && significand != 0) return 1;
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

    function checkIsZero ();
        if (exponent == 0 && significand == 0) return 1;
        else return 0;
    endfunction

    function checkIsMax ();
        if (exponent == 8'b1111_1110 && significand == 23'b111_1111_1111_1111_1111_1111) return 1;
        else return 0;
    endfunction

    function checkIsNormMin ();
        if (exponent == 8'b0000_0001 && significand == 0) return 1;
        else return 0;
    endfunction

    function checkIsDenormMin ();
        if (exponent == 8'b0000_0000 && significand == 23'b000_0000_0000_0000_0000_0001) return 1;
        else return 0;
    endfunction

endclass

class SignTestObj;
    FloatingPoint op1, op2;
    shortreal [7:0] expected_results;
    o_err_t [7:0] expected_err, actual_err;
    FloatingPoint [7:0] actual_results;

    function new();
        op1 = new();
        op2 = new();
    endfunction
endclass

typedef struct {
    int cc_id;
    fp_case case1, case2;
    fp_case [7:0] expected_type;
    o_err_t [7:0] expected error;
    op_pair [N-1:0] op_pairs;
} combo_case;

typedef struct {
    fp_t op1, op2;
    fp_t [7:0] expected_results;
    fp_t [7:0] actual_results;
    o_err_t [7:0] actual_errors;
} op_pair;

/////////////////////////////////////////////
// Functions that Test the Other Functions //
/////////////////////////////////////////////

function void FpUnpackTest (shortreal val);
    fp_t num;
    num = fpUnpack(val);
    // Print out the bits that make up this value:
    $display("Val = %0f", val);
    $display("Bits = %032b", num.bits);
    $display("sign bit = %01b, exponent = %08b, significand = %023b.", num.unpkg.sign, num.unpkg.exponent, num.unpkg.significand);
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


// TODO: Change the fp_t into a class, and have different classes
// with constrained random fields, and constructor methods which
// package it into an fp_t.


// This is a bad implementation. Should figure this out later..

// class FloatingPoint;
//     fp_t fp;
//     shortreal fp_sr;
//     bit sign;
//     bit [7:0] exponent;
//     bit [22:0] significand;

//     function new();
//         fp.unpkg.sign = sign;
//         fp.unpkg.exponent = exponent;
//         fp.unpkg.significand = significand;
//         fp_sr = fpPack(fp);
//     endfunction

//     function buildFP();
//         fp.unpkg.sign = sign;
//         fp.unpkg.exponent = exponent;
//         fp.unpkg.significand = significand;
//     endfunction

//     // Function which takes a shortreal and converts it into a fp_t type to work with in the FPU
//     function void fpUnpack ();
//         fp.bits = $shortrealtobits(fp_sr);
//     endfunction

//     // Function which takes a fp_t number and converts it to shortreal for printing/display.
//     function void fpPack ();
//         fp_sr = $bitstoshortreal(fp.bits);
//     endfunction

// endclass

// class RandReg extends FloatingPoint;
//     bit sign;
//     bit [7:0] exponent;
//     rand bit [22:0] sigificand;
//     constraint c {
//         exponent < 8'b1111_1111;
//         exponent > 8'b0000_0000;
//     }
// endclass

// class RandDenorm extends FloatingPoint;
//     static rand bit [7:0] exp = 0;
//     rand bit [22:0] sig;
//     constraint c {
//         sig > 23'd0;
//     }
// endclass

endpackage