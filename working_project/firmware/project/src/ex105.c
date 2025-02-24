#include "ex105.h"
#include "mathlib.h"

unsigned int convert(unsigned int x) {
    //convert farhenheit to celsius
    int multiplication = multiply(x, 5);
    int division = devide(multiplication, 9);
    return division - 32;
}