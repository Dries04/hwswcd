#include "ex102.h"

int multiply(int a, int b) {
    int a_new = 0;
    for (int i = 0; i < a; i++) {
        a = a + b;
    }
    return a;
}