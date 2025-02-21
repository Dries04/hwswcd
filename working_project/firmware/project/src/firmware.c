#include "print.h"
#include "ex102.h"

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
	int ok = multiply(3, 4);
	print_dec(ok);
}
