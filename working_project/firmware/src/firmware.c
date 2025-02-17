#include "print.h"

void main(void) {
	
	unsigned int x, y, z;
	unsigned int i;

	x = 1;
	y = 1;
    
	print_hex(x, 2);
	print_hex(y, 2);

	for(i=0;i<2;i++) {
		z = x + y;
		print_hex(z,2);
		x = y + z;
		print_hex(x,2);
		y = z + x;
		print_hex(y,2);
	}

	while(1);
}
