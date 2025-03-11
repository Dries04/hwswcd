#include "print.h"

int main() {

    while(1){
        *((volatile unsigned int*)0x80000000) = 0x01;
    }
    
    return 0;
}