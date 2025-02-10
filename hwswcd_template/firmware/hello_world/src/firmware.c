#include "print.h"
#include "tcnt.h"


extern unsigned int sw_mult(unsigned int x, unsigned int y);

struct matrix_t{
	unsigned int a00;
	unsigned int a10;
	unsigned int a01;
	unsigned int a11;
};

void matrix_mult(struct matrix_t * z, struct matrix_t * x, struct matrix_t * y) {
	z->a00 = sw_mult(x->a00, y->a00) + sw_mult(x->a10, y->a01);
	z->a10 = sw_mult(x->a00, y->a10) + sw_mult(x->a10, y->a11);
	z->a01 = sw_mult(x->a01, y->a00) + sw_mult(x->a11, y->a01);
	z->a11 = sw_mult(x->a01, y->a10) + sw_mult(x->a11, y->a11);
}

void print_matrix(struct matrix_t * x) {
	print_str("\r\n|");
	print_dec(x->a00);
	print_str("|");
	print_dec(x->a10);
	print_str("|\r\n|");
	print_dec(x->a01);
	print_str("|");
	print_dec(x->a11);
	print_str("|\r\n");
}

unsigned int main(void) {
	
	unsigned int i, tcnt;

	print_chr('h');
	print_str("ello world");
	print_str("\r\n");
	print_dec(314);
	print_str("\r\n");
/*
	for(i=1;i<1000;i++) {
		if((i & 0xF) == 0) {
			print_chr(';');
		} else if((i & 0x7) == 0) {
			print_chr(':');
		} else {
			print_chr('.');
		}

        tcnt = TCNT_VAL + 72;
		TCNT_start();
        while(TCNT_VAL < tcnt);
        TCNT_stop();
	}*/

	struct matrix_t m, n, o;
	
	m.a00 = 1; n.a00 = 5;
	m.a10 = 2; n.a10 = 6;
	m.a01 = 3; n.a01 = 7;
	m.a11 = 4; n.a11 = 8;

	TCNT_clear();
	TCNT_start();
	matrix_mult(&o, &m, &n);
	TCNT_stop();
	print_matrix(&o);
	
	tcnt = TCNT_VAL;
	print_dec(tcnt);



	return 0;
}
