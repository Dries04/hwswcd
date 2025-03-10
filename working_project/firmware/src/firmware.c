#include "print.h"
#include "ex105.h"
#define ADDR ((volatile unsigned int*)0x80000000)

void delay() {
    for (volatile unsigned int i = 0; i < 100000000; i++); // Simple delay loop
}

int main() {
    unsigned int value = 0x01;
    
    while (1) {
        *ADDR = value;
        
        value ^= 0x01; // Toggle between 0x01 and 0x00
        delay(); // Wait for a while
    }
    
    return 0;
}