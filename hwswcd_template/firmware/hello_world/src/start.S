#define STACK_SIZE 512


#define LOG_REGBYTES 2
#define REGBYTES (1 << LOG_REGBYTES)
#define INTEGER_CONTEXT_SIZE (32 * REGBYTES)


.global reset_vector
.global start
.global sw_mult

.section .init, "ax"

/* RESET VECTOR */
reset_vector:
    j do_reset


/* TRAP VECTOR (start at 0x10) */
.balign 16
trap_vector:
    csrrw sp, mscratch, sp
        /* in M-mode, mscratch has to be zero */
    bnez sp, error

    csrr sp, mscratch
    addi sp, sp, -INTEGER_CONTEXT_SIZE

	sw x1,   0*4(sp)
	sw x3,   3*4(sp)
	sw x4,   4*4(sp)
	sw x5,   5*4(sp)
	sw x6,   6*4(sp)
	sw x7,   7*4(sp)
	sw x8,   8*4(sp)
	sw x9,   9*4(sp)
	sw x10, 10*4(sp)
	sw x11, 11*4(sp)
	sw x12, 12*4(sp)
	sw x13, 13*4(sp)
	sw x14, 14*4(sp)
	sw x15, 15*4(sp)
	sw x16, 16*4(sp)
	sw x17, 17*4(sp)
	sw x18, 18*4(sp)
	sw x19, 19*4(sp)
	sw x20, 20*4(sp)
	sw x21, 21*4(sp)
	sw x22, 22*4(sp)
	sw x23, 23*4(sp)
	sw x24, 24*4(sp)
	sw x25, 25*4(sp)
	sw x26, 26*4(sp)
	sw x27, 27*4(sp)
	sw x28, 28*4(sp)
	sw x29, 29*4(sp)
	sw x30, 30*4(sp)
	sw x31, 31*4(sp)

    csrrc a0, mcause, zero
    jal ra, irq_handler

    lw x1,   0*4(sp)
	lw x3,   3*4(sp)
	lw x4,   4*4(sp)
	lw x5,   5*4(sp)
	lw x6,   6*4(sp)
	lw x7,   7*4(sp)
	lw x8,   8*4(sp)
	lw x9,   9*4(sp)
	lw x10, 10*4(sp)
	lw x11, 11*4(sp)
	lw x12, 12*4(sp)
	lw x13, 13*4(sp)
	lw x14, 14*4(sp)
	lw x15, 15*4(sp)
	lw x16, 16*4(sp)
	lw x17, 17*4(sp)
	lw x18, 18*4(sp)
	lw x19, 19*4(sp)
	lw x20, 20*4(sp)
	lw x21, 21*4(sp)
	lw x22, 22*4(sp)
	lw x23, 23*4(sp)
	lw x24, 24*4(sp)
	lw x25, 25*4(sp)
	lw x26, 26*4(sp)
	lw x27, 27*4(sp)
	lw x28, 28*4(sp)
	lw x29, 29*4(sp)
	lw x30, 30*4(sp)
	lw x31, 31*4(sp)

    add sp, zero, zero
    csrrw sp, mscratch, sp
    mret

irq_handler:
    nop
    jalr ra

.balign 32
do_reset:
    /* Clear registers */
    /*li x1, 123      /* this instruction would translate to "addi	ra,zero,123" */
    addi x1, zero, 0
    addi x2, zero, 0
	addi x3, zero, 0
	addi x4, zero, 0
	addi x5, zero, 0
	addi x6, zero, 0
	addi x7, zero, 0
	addi x8, zero, 0
	addi x9, zero, 0
	addi x10, zero, 0
	addi x11, zero, 0
	addi x12, zero, 0
	addi x13, zero, 0
	addi x14, zero, 0
	addi x15, zero, 0
	addi x16, zero, 0
	addi x17, zero, 0
	addi x18, zero, 0
	addi x19, zero, 0
	addi x20, zero, 0
	addi x21, zero, 0
	addi x22, zero, 0
	addi x23, zero, 0
	addi x24, zero, 0
	addi x25, zero, 0
	addi x26, zero, 0
	addi x27, zero, 0
	addi x28, zero, 0
	addi x29, zero, 0
	addi x30, zero, 0
	addi x31, zero, 0

    /* set stack pointer */
	lui sp,(256*1024)>>12

	/* set gp and tp */
	lui gp, %hi(0xdeadbeef)
	addi gp, gp, %lo(0xdeadbeef)
	addi tp, gp, 0

        /* Zicsr extension */
        /* csrr(w|s|c) rd, CSR_ID, rs1 */

    /* init interrupts */
    csrrwi x0, mscratch, 0

    /* write mtvec and make sure it sticks */
        /* la t0, SYMBOL is an assembler pseudo instruction that puts the address of SYMBOL
            into t0. Depending on the addressing mode, it expands to something like
                lui t0, SYMBOL[31:12]
                addi t0, t0, SYMBOL[11:0] */
    la t0, trap_vector
    csrrw x0, mtvec, t0
    csrrs t1, mtvec, x0
    bne t0, t1, error

start:
    /* enable interrupts */

    /* enable general interrupt*/
    csrrwi x0, mstatus, 8

    /* allow all external interrupts*/
    addi t0, zero, -1
    csrrw x0, mie, t0


    /* call main function */
    jal ra, main

	j final
	/* trap */
	ebreak


sw_mult: 
    bne a0, zero, sw_mult_init
    jalr zero, 0(ra)
sw_mult_init:
    add t1, a1, zero
    addi t0, a0, -1
    bne t0, zero, sw_mult_loop
    add a0, a1, zero
    jalr zero, 0(ra)
sw_mult_loop:
    add t1, t1, a1
    addi t0, t0, -1
    bne t0, zero, sw_mult_loop
    add a0, t1, zero
    jalr zero, 0(ra)


final:
    j final

error:
    j error


# .globl stacks
# stacks:
#   .skip RISCV_PGSIZE * MAX_HARTS

# .balign 4096-512
# .stack:
#     .skip STACK_SIZE
