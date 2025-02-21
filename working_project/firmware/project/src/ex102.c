#include "ex102.h"

int multiply(int a, int b) {
    int a_new = a;
    for (int i = 0; i < a; i++) {
        a_new = a_new + b;
    }
    return a;
}