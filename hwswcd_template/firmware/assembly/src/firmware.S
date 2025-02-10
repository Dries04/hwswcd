/*****************************************************************************/
/* This assembly script is used for initialisation.
   A section is made " init" to be used in the linker script
   In order to have the start function "findable" for linker, the global
     keywrod is added
/*****************************************************************************/
#define LOG_REGBYTES 2
#define REGBYTES (1 << LOG_REGBYTES)
#define INTEGER_CONTEXT_SIZE (32 * REGBYTES)

.globl reset_vector
.globl start
.section .init, "ax"

/* RESET VECTOR */
reset_vector:
    j do_reset

.balign 32
do_reset:
    /* Clear registers */
    add x1, zero, zero
    add x2, zero, zero
	add x3, zero, zero
	add x4, zero, zero
	add x5, zero, zero
	add x6, zero, zero
	add x7, zero, zero
	add x8, zero, zero
	add x9, zero, zero
	add x10, zero, zero
	add x11, zero, zero
	add x12, zero, zero
	add x13, zero, zero
	add x14, zero, zero
	add x15, zero, zero
	add x16, zero, zero
	add x17, zero, zero
	add x18, zero, zero
	add x19, zero, zero
	add x20, zero, zero
	add x21, zero, zero
	add x22, zero, zero
	add x23, zero, zero
	add x24, zero, zero
	add x25, zero, zero
	add x26, zero, zero
	add x27, zero, zero
	add x28, zero, zero
	add x29, zero, zero
	add x30, zero, zero
	add x31, zero, zero

    /* set stack pointer */
	lui sp,(256*1024)>>12

	/* set gp and tp */
	lui gp, %hi(0xdeadbeef)
	addi gp, gp, %lo(0xdeadbeef)
	addi tp, gp, 0

    /* call main function */
    jal ra, start

    /* trap */
    ebreak


start:
    addi t0, zero, 1
    add t1, zero, zero
    addi t2, zero, 128

loop:
    add t1, t0, t1
    beq t1, t2, done
    j loop

done:
    addi a0, zero, 0x2A
    jal ra, print_chr
    j final

final:
    j final

error:
    j error


print_chr: 
	lui	a5,0x80000
	sw a0, 0(a5)
	jalr zero, 0(ra)
