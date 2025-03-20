#include "tcnt.h"

#define LED_BASEAxDDRESS 0x80000000


#define LED_REG0_ADDRESS (LED_BASEAxDDRESS + 0*4)

#define LED              (*(volatile unsigned int *) LED_REG0_ADDRESS)

int one_sec_bool = 0;

void irq_handler(unsigned int cause) {

    if (cause & 4) {
        LED = 0xFFFFFFFF;
    }

    one_sec_bool++;


    TCNT_CR = 0x17;
    TCNT_CR = 0x7;

}


void main(void) {
    
    unsigned int i=1, j;

    TCNT_CMP = 0xFFF;
    TCNT_start();

    while(1) {
        if (one_sec_bool == 1) {
            one_sec_bool = 0;
            if(i < 15){
                i++;
            }else{
                i = 1;
            }
        }
        LED = i;
    }
}
