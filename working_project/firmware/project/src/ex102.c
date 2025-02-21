#include "ex102.h"

int multiply(int a, int b) {
    for (int i = 0; i < b; i++) {
        a = a + b;
    }
    return a;
}