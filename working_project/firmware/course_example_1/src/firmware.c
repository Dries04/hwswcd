#include "tcnt.h"

#define LED_BASEAxDDRESS 0x80000000


#define LED_REG0_ADDRESS (LED_BASEAxDDRESS + 0*4)

#define LED              (*(volatile unsigned int *) LED_REG0_ADDRESS)

int i = 1;


void irq_handler(unsigned int cause) {

    if (cause & 4) {
        LED = 0xFFFFFFFF;
    }
    if(i < 8){
        LED = i;
        i++;
    }else{
        i = 1;
    }

    TCNT_CR = 0x17;
    TCNT_CR = 0x7;

}


void main(void) {
    
    //unsigned int i=1, j;

    TCNT_CMP = 0xC65D40;
    TCNT_start();

    while(1) {

    }
}
