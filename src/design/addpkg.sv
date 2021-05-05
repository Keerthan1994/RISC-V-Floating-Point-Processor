package addpkg;

typedef struct packed {
    bit sign;
    bit [7:0] exponent;
    bit [22:0] significand;
} ieee754_sp_t;             // Breaks the 32-bit short real into bits

// Generic floating point type to use for unpacking
typedef union {
    bit [31:0] bits;        // Shortreal (32 bit) Float value
    ieee754_sp_t un;        // Single Precision Floating Point Unpacked
} fp_t;


function fp_t fpUnpack (shortreal val);
    fp_t fp;
    fp.bits = $shortrealtobits(val);
    return fp;
endfunction

/* Example of use. */
function void FpUnpackTest (shortreal val);
    fp_t num;
    num = fpUnpack(val);
    // Print out the bits that make up this value:
    $display("Val = %0f", val);
    $display("Bits = %032b", num.bits);
    $display("sign bit = %01b, exponent = %08b, significand = %023b.", num.un.sign, num.un.exponent, num.un.significand);
endfunction

endpackage