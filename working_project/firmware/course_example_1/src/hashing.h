#ifndef HASHING_H
#define HASHING_H

#include <stdint.h>

// Base address for the hashing peripheral
#define HASHING_BASE_ADDR   0x83000000

// Register offsets (each is 4 bytes apart)
#define HASHING_R_OFFSET    0x00
#define HASHING_G_OFFSET    0x04
#define HASHING_B_OFFSET    0x08
#define HASHING_A_OFFSET    0x0C
#define HASHING_CTRL_OFFSET 0x10
#define HASHING_RESULT_OFFSET HASHING_CTRL_OFFSET  // result read from same

// Function to compute hash of an RGBA pixel
uint8_t hashing_compute(uint8_t r, uint8_t g, uint8_t b, uint8_t a);

#endif // HASHING_H
