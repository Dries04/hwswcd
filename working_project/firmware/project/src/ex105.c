#include "ex105.h"

int multiply(int a, int b) {
    int result = 0;
    while (b > 0) {
        result += a;
        b--;
    }
    return result;
}

int divide(int a, int b) {
    int quotient = 0;
    while (a >= b) {
        a -= b;
        quotient++;
    }
    return quotient;
}

unsigned int convert(unsigned int x) {
    int temp = x;
    
    // Subtract 32 (manually)
    int sub = 32;
    temp = x - sub;

    // Multiply by 5 (using addition)
    temp = multiply(temp, 5);

    // Divide by 9 (using subtraction)
    temp = divide(temp, 9);

    return temp;
}