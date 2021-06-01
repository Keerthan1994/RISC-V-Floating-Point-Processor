package addpkg;

// Special Cases For Input Operands
typedef enum logic [1:0] {
    NOERR, ZERO, NAN, INF
} i_err_t;

// Error Codes
typedef enum logic [2:0] {
    NONE, INVALID, DIVBYZERO, OVERFLOW, UNDERFLOW, INEXACT
} o_err_t;

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

// Function that changes the sign bit of a given fp_t to the
// specified sign and returns the fp_t.
function fp_t changeSign (fp_t val, bit sign);
    val.unpkg.sign = sign;
    return val;
endfunction

// Function that generates a random fp_t value of a particular sign
function fp_t createRandReg (bit sign);
    fp_t fp;
    fp.unpkg.sign = sign;
    // Bounded random for exponent and sig
    fp.unpkg.exponent = $urandom();
    if (fp.unpkg.exponent == 8'b1111_1111) fp_unpkg.exponent -= 1'b1;
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

/* Example Functions */
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