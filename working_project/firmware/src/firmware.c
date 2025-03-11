#include "print.h"
#include "ex105.h"

void delay() {
    for (volatile unsigned int i = 0; i < 400000; i++); // Simple delay loop
}

int main() {
    
    int value = 0;

    while (1) {

        for (int i = 0; i < 16; i++) {
            value = value + 1;
            *((volatile unsigned int*)0x80000000) = value;
            delay();
        }

    }

    
    return 0;
}