/*****************************************************************************/
/* This assembly script is used for initialisation.
   A section is made " init" to be used in the linker script
   In order to have the start function "findable" for linker, the global
     keywrod is added
/*****************************************************************************/
.global start
.global sw_mult
.section .init, "ax"

start:
  /* zero-initialize all registers */
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
  lui sp, %hi(4*1024)

  /* call main */
  jal ra, main
  j end

  /* break - trap */
  ebreak

end:
  j end


# Software multiplication. It returns the product of a0 and a1
sw_mult: 
    # Return a0, in case it is 0x0
    bne a0, zero, sw_mult_init
    jalr zero, 0(ra)
sw_mult_init:
    # Initialise t0 (=x-1) and t1 (=y)
    add t1, a1, zero
    addi t0, a0, -1
    # Return y if t0 is 0x0
    bne t0, zero, sw_mult_loop
    add a0, a1, zero
    jalr zero, 0(ra)
sw_mult_loop:
    # Add (t1 += a1) and substract (t0--)
    add t1, t1, a1
    addi t0, t0, -1
    # Check to see if the operation is done
    bne t0, zero, sw_mult_loop
    add a0, t1, zero
    jalr zero, 0(ra)

