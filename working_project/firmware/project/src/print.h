// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

#ifndef PRINT_H
#define PRINT_H

#define OUTPORT 0x80000000


// print.c
void print_chr(char ch);
void print_str(const char *p);
void print_dec(unsigned int val);
int getDigit(int base, int number);
int multiply(int a, int b);
int devide(int a, int b);
void print_hex(unsigned int val, int digits);

#endif
