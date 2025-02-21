#include "print.h"

// int multiply(int a, int b) {
//     int a_new = a;
//     for (int i = 0; i < b - 1; i++) {
//         a_new = a_new + a;
//     }
//     return a_new;
// }

int main(void) {

	print_str("hello world\n");
	unsigned int test = 12;
	print_dec(test);
	unsigned int test1 = 69;
	print_dec(test1);
	unsigned int test3 = 10;
	print_dec(test3);
	unsigned int test4 = 20;
	print_dec(test4);
	unsigned int test2 = 500;
	print_dec(test2);
}
