#include "ex102.h"

int multiply(int a, int b) {
    int a_new = a;
    for (int i = 0; i < b - 1; i++) {
        a_new = a_new + a;
    }
    return a_new;
}