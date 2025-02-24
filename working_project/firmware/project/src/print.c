// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

#include "print.h"
#include "mathlib.h"

int multiply(int a, int b);
int divide(int a, int b);

void print_chr(char ch) {
	*((volatile unsigned int*)OUTPORT) = ch;
}

void print_str(const char *p) {
	while (*p != 0)
		*((volatile unsigned int*)OUTPORT) = *(p++);
}

unsigned int number_length[] = {0,1,10,100,1000,10000,100000,1000000,10000000};

int getNumber(int length, int val) {
	return divide(val, length);
}

void print_dec(unsigned int val) {
	if (val == 0){
		print_chr('0');
		print_str("\n");
		return;
	}
    char first_1 = 0;
    for (int i = 8; i > 0; i--)
    {
        int index = getNumber(number_length[i],val);
        if (index != 0 || first_1 != 0)
        {
            first_1 = 1;
            char x="0123456789"[index];
            *((volatile unsigned int*)OUTPORT) = x;
        }
        for (int j = 0; j < index; j++){
            val -= number_length[i];
        }
    }
    print_str("\n");
    return;
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