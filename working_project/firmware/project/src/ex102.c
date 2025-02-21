#include "ex102.h"

int multiply(int a, int b) {
    int a_new = 0;
    for (int i = 0; i < b-1; i++) {
        a = a + b;
        a_new = a_new + a;
    }
    return a_new;
}