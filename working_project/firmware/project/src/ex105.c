#include "ex105.h"
#include "mathlib.h"

unsigned int convert(unsigned int x) {
    //convert farhenheit to celsius
    int z = x - 32;
    int w = devide(5, 9);
    int a_new = z;
    for (int i = 0; i < w - 1; i++) {
        a_new = a_new + w;
    }
    return a_new;

}