// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

#include "print.h"

void print_chr(char ch) {
	*((volatile unsigned int*)OUTPORT) = ch;
}

void print_str(const char *p) {
	while (*p != 0)
		*((volatile unsigned int*)OUTPORT) = *(p++);
}

void print_dec(unsigned int val) {
	
	unsigned int divisor = 1000000000;  // Start with the largest place value for a 32-bit integer
    unsigned int digit;
    int leading_zero = 1;  // Used to skip leading zeros

    if (val == 0) {  // Special case: print "0" directly
        print_chr('0');
        return;
    }

    // Iterate through each place value from 1 billion down to 1
    while (divisor >= 1) {
        // Determine the digit for the current place value
        digit = 0;
        while (val >= divisor) {  // Use repeated subtraction to find the digit
            val -= divisor;
            digit += 1;
        }

        // Print the digit if it's non-zero or if we've already printed a previous digit
        if (digit != 0 || !leading_zero) {
            print_chr('0' + digit);  // Convert the digit to its ASCII character
            leading_zero = 0;  // Once we print the first non-zero digit, stop skipping zeros
        }

        // Move to the next lower place value
        divisor -= divisor >> 1; // Equivalent to `divisor /= 10` but using subtraction and shifting
    }

}

void print_hex(unsigned int val, int digits) {
	unsigned int index, max;
	int i; /* !! must be signed, because of the check 'i>=0' */
	char x;

	if(digits == 0)
		return;

	max = digits << 2;

	for (i = max-4; i >= 0; i -= 4) {
		index = val >> i;
		index = index & 0xF;
		x="0123456789ABCDEF"[index];
		*((volatile unsigned int*)OUTPORT) = x;
	}
	print_str("\n");
}
