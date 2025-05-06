#include "hashing.h"

volatile uint32_t* hashing_reg = (volatile uint32_t*)HASHING_BASE_ADDR;

uint8_t hashing_compute(uint8_t r, uint8_t g, uint8_t b, uint8_t a) {
    // Write color components
    hashing_reg[0] = r;
    hashing_reg[1] = g;
    hashing_reg[2] = b;
    hashing_reg[3] = a;

    // Trigger hash calculation
    hashing_reg[4] = HASHING_BASE_ADDR;  // dummy write as command

    // Read result (only lower 6 bits valid)
    uint32_t result = hashing_reg[4];

    return result & 0x3F;
}
