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
	int test3 = 0;
	multiply(5, 5, &test3);
	print_dec(test3);
}
