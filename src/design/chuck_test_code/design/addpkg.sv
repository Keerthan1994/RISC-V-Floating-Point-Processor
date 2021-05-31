package addpkg;

// Special Cases For Input Operands
typedef enum logic [1:0] {
    NOERR, ZERO, NAN, INF
} i_err_t;

// Error Codes
typedef enum logic [2:0] {
    NONE, INVALID, DIVBYZERO, OVERFLOW, UNDERFLOW, INEXACT
} o_err_t;

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

function fp_t fpUnpack (shortreal val);
    fp_t fp;
    fp.bits = $shortrealtobits(val);
    return fp;
endfunction

function shortreal fpPack (fp_t val);
    shortreal fp;
    fp = $bitstoshortreal(val.bits);
    return fp;
endfunction

/* Example of use. */
function void FpUnpackTest (shortreal val);
    fp_t num;
    num = fpUnpack(val);
    // Print out the bits that make up this value:
    $display("Val = %0f", val);
    $display("Bits = %032b", num.bits);
    $display("sign bit = %01b, exponent = %08b, significand = %023b.", num.unpkg.sign, num.unpkg.exponent, num.unpkg.significand);
endfunction

function bit checkIsNaN (fp_t fp);
    if (fp.unpkg.exponent == 8'hFF && fp.unpkg.significand != 0) return 1;
    else return 0;
endfunction

function bit checkIsInf (fp_t fp);
    if (fp.unpkg.exponent == 8'hFF && fp.unpkg.significand == 0) return 1;
    else return 0;
endfunction

function bit checkIsSignedNaN (fp_t fp, bit sign);
    if (fp.unpkg.sign == sign && fp.unpkg.exponent == 8'hFF && fp.unpkg.significand != 0) return 1;
    else return 0;
endfunction

function bit checkIsSignedInf (fp_t fp, bit sign);
    if (fp.unpkg.sign == sign && fp.unpkg.exponent == 8'hFF && fp.unpkg.significand == 0) return 1;
    else return 0;
endfunction

function fp_t createNaN (bit sign);
    fp_t fp;
    fp.unpkg.sign = sign;
    fp.unpkg.exponent = '1;
    fp.unpkg.signficand = '1;
    return fp;
endfunction

function fp_t createInf (bit sign);
    fp_t fp;
    fp.unpkg.sign = sign;
    fp.unpkg.exponent = '1;
    fp.unpkg.signficand = '0;
    return fp;
endfunction

endpackage