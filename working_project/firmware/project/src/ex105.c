#include "ex105.h"
#include "mathlib.h"

unsigned int convert(unsigned int x) {
    //convert farhenheit to celsius
    int w = 0;
    int z = x - 32;
    w = multiply(z, 5);
    return w;
}