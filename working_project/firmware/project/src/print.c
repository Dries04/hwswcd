// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

#include "print.h"

int multiply(int a, int b);
int devide(int a, int b);

void print_chr(char ch) {
	*((volatile unsigned int*)OUTPORT) = ch;
}

void print_str(const char *p) {
	while (*p != 0)
		*((volatile unsigned int*)OUTPORT) = *(p++);
}

void print_dec(unsigned int val) {

	if (val >= 10){
		unsigned int quotient = 0;
		int length_int = 0;
		int devisor = 1;
	
		for (int i = 10; val >= multiply(i, 10); i = multiply(i, 10)){
			length_int++;
		}
		while (length_int >= 0){
			int temp = multiply(10, devisor);
			devisor = temp;
			length_int--;
		}
		//int devisor = multiply(10, length_int);
		//new implementation for all values
		while (val >= 10){
			//quotient = devide(val, devisor);
			int temp = 1;
			int quotient1 = 0;
			int val1 = val;
			int devisor1 = devisor;
			while (devisor1 <= val1) {
				devisor1 <<= 1;
				temp <<= 1;
			}
		
			while (temp > 1) {
				devisor1 >>= 1;
				temp >>= 1;
		
				if (val1 >= devisor1) {
					val1 -= devisor1;
					quotient1 += temp;
				}
			}
			
			//val = val - multiply(quotient, devisor);
			int a_new = quotient;
			for (int i = 0; i < devisor - 1; i++) {
				a_new = a_new + quotient;
			}
			val = val - a_new;
			print_chr('0' + quotient);
			if (val < 10){
				print_chr('0' + val);
				print_str("\n");
			}
		}

		// while (val >= 10){
		// 	quotient = devide(val, 10);
		// 	val = val - multiply(quotient, 10);
		// 	print_chr('0' + quotient);
		// 	if (val < 10){
		// 		print_chr('0' + val);
		// 		print_str("\n");
		// 	}
		// }


		// code die werkt van 0-99
		// while (val >= 10){
		// 	val = val -= 10;
		// 	quotient++;
		// }
		
		// print_chr('0' + quotient);
		// print_chr('0' + val);
		// print_str("\n");
	}else if (val < 10 ){
		print_chr('0' + val);
		print_str("\n");
	}else if(val == 10){
		print_chr('1');
		print_chr('0');
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

int devide(int a, int b) {
    int temp = 1;
    int quotient = 0;

    while (b <= a) {
        b <<= 1;
        temp <<= 1;
    }

    while (temp > 1) {
        b >>= 1;
        temp >>= 1;

        if (a >= b) {
            a -= b;
            quotient += temp;
        }
    }

    return quotient;
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