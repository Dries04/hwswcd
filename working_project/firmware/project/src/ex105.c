#include "ex105.h"
#include "mathlib.h"

unsigned int convert(unsigned int x) {
    int temp = x;
    
    int sub = 32;
    temp = x - sub;

    int b = 5;
    int a = temp;
    while (b > 1) {
        temp += a;
        b--;
    }

    temp = divide(temp, 9);

    return temp;
}