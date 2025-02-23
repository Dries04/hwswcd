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

//  void print_dec(unsigned int val) {

	// if (val >= 10){
	// 	unsigned int quotient = 0;
	// 	int length_int = 1;
	// 	int devisor = 1;
	
	// 	for (int i = 10; val >= multiply(i, 10); i = multiply(i, 10)){
	// 		length_int++;
	// 	}
	// 	while (length_int >= 0){
	// 		int temp = multiply(10, devisor);
	// 		devisor = temp;
	// 		length_int--;
	// 	}

	// 	int devisor_temp = devisor;
	// 	int val_temp = val;

	// 	while (val_temp >= 10){
			
			
	// 		//quotient = devide(val, devisor);
			
	// 		int temp = 1;
	// 		int quotient1 = 0;
	// 		int a = val_temp;
	// 		int b = devisor_temp;
	// 		int d = devisor_temp;

	// 		while (b <= a) {
	// 			b <<= 1;
	// 			temp <<= 1;
	// 		}
		
	// 		while (temp > 1) {
	// 			b >>= 1;
	// 			temp >>= 1;
		
	// 			if (a >= b) {
	// 				a -= b;
	// 				quotient1 += temp;
	// 			}
	// 		}

	// 		int c = quotient1;
	// 		//val = val - multiply(quotient, devisor);

	// 		int a_new = c;
	// 		for (int i = 0; i < d - 1; i++) {
	// 			a_new = a_new + c;
	// 		}
	// 		val_temp = val_temp - a_new;
			
	// 		//devisor_temp = devisor_temp / 10;

	// 		int temp2 = 1;
	// 		int quotient2 = 0;
	// 		int hihi = 10;
		
	// 		while (hihi <= a) {
	// 			hihi <<= 1;
	// 			temp2 <<= 1;
	// 		}
		
	// 		while (temp2 > 1) {
	// 			hihi >>= 1;
	// 			temp2 >>= 1;
		
	// 			if (devisor_temp >= 10) {
	// 				devisor_temp -= 10;
	// 				quotient2 += temp2;
	// 			}
	// 		}

	// 		devisor_temp = quotient2;

	// 		print_chr('0' + quotient1);
	// 		if (val_temp < 10){
	// 			print_chr('0' + val_temp);
	// 			print_str("\n");
	// 		}
	// 	}

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
	// }else if (val < 10 ){
	// 	print_chr('0' + val);
	// 	print_str("\n");
	// }else if(val == 10){
	// 	print_chr('1');
	// 	print_chr('0');
	// 	print_str("\n");
	// }



//}


unsigned int base_lookup[] = {0,1,10,100,1000,10000,100000,1000000,10000000,100000000,1000000000};

void print_dec(unsigned int val) {
    char leading_0_flag = 0;
    for (int i = 10; i > 0; i--)
    {
        //print_str("i: ");
        //print_hex(i,8);
        //print_str("\n");
        int index = getDigit(base_lookup[i],val);
        if (index != 0 || leading_0_flag != 0)
        {
            leading_0_flag = 1;
            char x="0123456789"[index];
            *((volatile unsigned int*)OUTPORT) = x;
        }
        for (int j = 0; j < index; j++){
            val -= base_lookup[i];
        }
    }
    print_str("\n");
    return;
}
int getDigit(int base, int number) {
    //print_str("number: ");
    //print_hex(number,8);
    //print_str("\n");
    //print_str("base: ");
    //print_hex(base,8);
    //print_str("\n");
    int digit = 0;
    for (int i = base;i <= number;i += base) ++digit;
    //print_str("digit: ");
    //print_hex(digit,1);
    //print_str("\n");
    return digit;
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