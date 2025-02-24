#include "ex105.h"
#include "mathlib.h"

unsigned int convert(unsigned int x) {
    //convert farhenheit to celsius
    int z = x - 32;
    int w = devide(5, 9);
    return multiply(z, w);
}