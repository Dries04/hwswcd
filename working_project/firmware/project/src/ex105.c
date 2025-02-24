#include "ex105.h"

unsigned int convert(unsigned int x) {
    int temp = x;
    
    // Subtract 32 (manually)
    int sub = 32;
    temp = x - sub;

    // Multiply by 5 (using addition)
    int b = 5;
    int a = temp;
    while (b > 0) {
        temp += a;
        b--;
    }

    // Divide by 9 (using subtraction)
    // temp = divide(temp, 9);

    return temp;
}