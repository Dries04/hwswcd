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
	//check lenght of int
	int val_lenght = 0;
	int original_val = val;
	unsigned int quotient = 0;
	
	// while (val) {
    //     str[i++] = (num % 10) + '0';  // Convert digit to char
    //     num /= 10;
    // }

    // for (int j = i - 1; j >= 0; j--) {
    //     putchar(str[j]);  // Print each digit in reverse order
	// }

	// devide without devision
	if (val > 10){
		while (val > 10){
			val = val -= 10;
			quotient++;
		}
	}

	unsigned int print_val = original_val;
	if (print_val < 10 ){
		print_chr('0' + print_val);
		print_str("\n");
	} else {
		print_str("something went wrong :(\n");
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
