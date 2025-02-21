// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

#include "print.h"

int multiply(int a, int b);

void print_chr(char ch) {
	*((volatile unsigned int*)OUTPORT) = ch;
}

void print_str(const char *p) {
	while (*p != 0)
		*((volatile unsigned int*)OUTPORT) = *(p++);
}

void print_dec(unsigned int val) {
	int val_lenght = 0;
	int original_val = val;
	unsigned int quotient = 0;

	// for (int i = 1; val > multiply(10, i); i = multiply (i, 10)){
	// 	val_lenght++;
	// 	print_dec(val_lenght);
	// }

	if (val >= 10){
		
		while (val >= 10){
			val = val -= 10;
			quotient++;
		}
		print_chr('0' + quotient);
		print_chr('0' + val);
		print_str("\n");
	}

	unsigned int print_val = original_val;
	if (print_val < 10 ){
		print_chr('0' + print_val);
		print_str("\n");
	}
}

int multiply(int a, int b) {
    int a_new = a;
    for (int i = 0; i < b - 1; i++) {
        a_new = a_new + a;
    }
    return a_new;
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
