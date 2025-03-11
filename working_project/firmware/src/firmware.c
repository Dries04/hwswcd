#include "print.h"
#include "ex105.h"

void delay() {
    for (volatile unsigned int i = 0; i < 4000000; i++); // Simple delay loop
}

int main() {
    unsigned int value = 0x01;
    
    while (1) {
        
        *((volatile unsigned int*)0x80000000) = value; // Output the value to the LED  
        value = 0x01; // Toggle between 0x01 and 0x00
        delay();
        value = 0x02;
        delay();
        value = 0x04;
        delay();
        value = 0x08;
        delay();
        value = 0x0F;
        delay();
    }
    
    return 0;
}