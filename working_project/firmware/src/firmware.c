#include "print.h"
#include "tcnt.h"

extern unsigned int sw_mult(unsigned int x, unsigned int y);

struct matrix_t {
    unsigned int a00, a01, a02;
    unsigned int a10, a11, a12;
    unsigned int a20, a21, a22;
};

void matrix_mult(struct matrix_t *z, struct matrix_t *x, struct matrix_t *y) {
    z->a00 = sw_mult(x->a00, y->a00) + sw_mult(x->a01, y->a10) + sw_mult(x->a02, y->a20);
    z->a01 = sw_mult(x->a00, y->a01) + sw_mult(x->a01, y->a11) + sw_mult(x->a02, y->a21);
    z->a02 = sw_mult(x->a00, y->a02) + sw_mult(x->a01, y->a12) + sw_mult(x->a02, y->a22);
    
    z->a10 = sw_mult(x->a10, y->a00) + sw_mult(x->a11, y->a10) + sw_mult(x->a12, y->a20);
    z->a11 = sw_mult(x->a10, y->a01) + sw_mult(x->a11, y->a11) + sw_mult(x->a12, y->a21);
    z->a12 = sw_mult(x->a10, y->a02) + sw_mult(x->a11, y->a12) + sw_mult(x->a12, y->a22);
    
    z->a20 = sw_mult(x->a20, y->a00) + sw_mult(x->a21, y->a10) + sw_mult(x->a22, y->a20);
    z->a21 = sw_mult(x->a20, y->a01) + sw_mult(x->a21, y->a11) + sw_mult(x->a22, y->a21);
    z->a22 = sw_mult(x->a20, y->a02) + sw_mult(x->a21, y->a12) + sw_mult(x->a22, y->a22);
}

int main() {
    unsigned int tcnt;
    struct matrix_t m, n, o;

    m.a00 = 1; m.a01 = 2; m.a02 = 3;
    m.a10 = 4; m.a11 = 5; m.a12 = 6;
    m.a20 = 7; m.a21 = 8; m.a22 = 9;

    n.a00 = 9; n.a01 = 8; n.a02 = 7;
    n.a10 = 6; n.a11 = 5; n.a12 = 4;
    n.a20 = 3; n.a21 = 2; n.a22 = 1;

    TCNT_start();
    matrix_mult(&o, &m, &n);
    TCNT_stop();
    tcnt = TCNT_VAL;
    print_dec(tcnt);
    
    return 0;
}
