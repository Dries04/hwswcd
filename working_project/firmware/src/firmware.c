#include "print.h"
#include "ex105.h"

int main(void) {
	
	int led = 0;
	// laat ledje elke seconde knipperen
	for (int i = 0; i < 100; i++) {
		for (int j = 0; j < 40000000; j++) {
			if (led == 0) {
				led = 1;
				*((volatile unsigned int*)0x80000000) = 0x01;
			} else {
				led = 0;
				*((volatile unsigned int*)0x80000000) = 0x00;
			}
			// zet ledje aan of uit
		}
	}
}