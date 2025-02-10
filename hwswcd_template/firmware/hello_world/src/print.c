// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

#include "print.h"

void print_chr(char ch)
{
	*((volatile unsigned int*)OUTPORT) = ch;
}

void print_str(const char *p)
{
	while (*p != 0)
		*((volatile unsigned int*)OUTPORT) = *(p++);
}

void _print_dec(unsigned int val)
{
	unsigned int temp_tens = 0;
	char x;

	while(val >= 10) {
		temp_tens += 1;
		val -= 10;
	}

	if (temp_tens < 10) {
		x = '0' + temp_tens;
		*((volatile unsigned int*)OUTPORT) = x;
	} else {
		_print_dec(temp_tens);
	}

	x = '0' + val;
	*((volatile unsigned int*)OUTPORT) = x;
}


void print_dec(unsigned int val)
{
	unsigned int temp_tens = 0;
	char x;

	while(val >= 10) {
		temp_tens += 1;
		val -= 10;
	}

	if (temp_tens < 10) {
		x = '0' + temp_tens;
		*((volatile unsigned int*)OUTPORT) = x;
	} else {
		_print_dec(temp_tens);
	}

	x = '0' + val;
	*((volatile unsigned int*)OUTPORT) = x;
	print_chr('\n');
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
