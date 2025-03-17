#include "print.h"
#include "tcnt.h"

extern unsigned int sw_mult(unsigned int x, unsigned int y);



int main() {

	for (int i = 0; i < 10; i++) {
		print_hex(i, 8);
		print_str("\n");
	}

	// print_dec(5);
	// print_str("\n");
	// print_dec(6);
	// print_str("\n");
	// print_dec(sw_mult(5, 6));
	// print_str("\n");
	

	// unsigned int tcnt;
	// struct matrix_t m, n, o;
	
	// m.a00 = 1; n.a00 = 5;
	// m.a10 = 2; n.a10 = 6;
	// m.a01 = 3; n.a01 = 7;
	// m.a11 = 4; n.a11 = 8;

	// TCNT_start();
	// matrix_mult(&o, &m, &n);
	// TCNT_stop();
	// tcnt = TCNT_VAL;
	// print_dec(tcnt);

    return 0;
}