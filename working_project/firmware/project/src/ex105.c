#include "ex105.h"
#include "mathlib.h"

unsigned int convert(unsigned int x) {
    //convert farhenheit to celsius
    int z = x - 32;
    int y = multiply(z, 5);
    return devide(y, 9);
}