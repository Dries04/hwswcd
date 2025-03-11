#include "print.h"
#include "ex105.h"

void delay() {
    for (volatile unsigned int i = 0; i < 400000; i++); // Simple delay loop
}

int main() {
    
    int value = 0;

    while (1) {
        
         
        value = 1; // Toggle between 0x01 and 0x00
        *((volatile unsigned int*)0x80000000) = value; // Output the value to the LED 
        delay(); // Delay for a while
        value = 2;
        *((volatile unsigned int*)0x80000000) = value; // Output the value to the LED
        delay(); // Delay for a while
        value = 4;
        *((volatile unsigned int*)0x80000000) = value; // Output the value to the LED
        delay(); // Delay for a while
        value = 8;
        *((volatile unsigned int*)0x80000000) = value; // Output the value to the LED
        delay(); // Delay for a while
        value = 16;
        *((volatile unsigned int*)0x80000000) = value; // Output the value to the LED
        delay(); // Delay for a while

    }

    
    return 0;
}