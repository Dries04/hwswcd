#include "print.h"
#include "ex105.h"

int main(void) {

	print_str("hello world\n");
	unsigned int test5 = 495;
	print_dec(test5);
	unsigned int test6 = convert(test5);
	print_dec(test6);

}
