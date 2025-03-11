#include "print.h"
#include "ex105.h"

void delay() {
    for (volatile unsigned int i = 0; i < 4000000; i++); // Simple delay loop
}

int main() {
    unsigned int value = 0x01;
    
    while (1) {
        
        *((volatile unsigned int*)0x80000000) = value; // Output the value to the LED  
        value = 1; // Toggle between 0x01 and 0x00
        delay();
        value = 2;
        *((volatile unsigned int*)0x80000000) = value; // Output the value to the LED  
        delay();
        value = 3;
        *((volatile unsigned int*)0x80000000) = value; // Output the value to the LED
        delay();
        value = 4;
        *((volatile unsigned int*)0x80000000) = value; // Output the value to the LED
        delay();
        value = 5;
        *((volatile unsigned int*)0x80000000) = value; // Output the value to the LED
        delay();
        value = 6;
        *((volatile unsigned int*)0x80000000) = value; // Output the value to the LED
        delay();
        value = 7;
        *((volatile unsigned int*)0x80000000) = value; // Output the value to the LED
        delay();
        value = 8;
        *((volatile unsigned int*)0x80000000) = value; // Output the value to the LED
        delay();
        value = 9;
        *((volatile unsigned int*)0x80000000) = value; // Output the value to the LED
        delay();
        value = 10;
        *((volatile unsigned int*)0x80000000) = value; // Output the value to the LED
        delay();
        value = 11;
        *((volatile unsigned int*)0x80000000) = value; // Output the value to the LED
        delay();
        value = 12;
        *((volatile unsigned int*)0x80000000) = value; // Output the value to the LED
        delay();
    }
    
    return 0;
}