package addpkg;

typedef packed struct {
    bit sign;
    bit [7:0] exponent;
    bit [22:0] significand;
} ieee754_sp_t;             // Breaks the 32-bit short real into bits

// Generic floating point type to use for unpacking
typedef union {
    shortreal fp_val;       // Shortreal (32 bit) Float value
    ieee754_sp_t fp_un;     // Single Precision Floating Point Unpacked
} fp_t;

/* Example of use. */
function void FpUnpackTest (shortreal val);
    fp_t num;               // declare the fp_t variable:
    num.fp_val = val;       // Set the value of the variable to a float value
    // Print out the bits that make up this value:
    $display("sign bit = %0b, exponent = %0b, significand = %0b.", num.fp_un.sign, num.fp_un.exponent, num.fp_un.significand);
endfunction

endpackage