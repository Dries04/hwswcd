.global start

.section .init, "ax"

start:
  addi x1, x0, 0
  addi x2, x0, 0
  addi x3, x0, 0
  addi x4, x0, 0
  addi x5, x0, 0
  addi x6, x0, 0
  addi x7, x0, 0
  addi x8, x0, 0
  addi x9, x0, 0
  addi x10, x0, 0
  addi x11, x0, 0
  addi x12, x0, 0
  addi x13, x0, 0
  addi x14, x0, 0
  addi x15, x0, 0
  addi x16, x0, 0
  addi x17, x0, 0
  addi x18, x0, 0
  addi x19, x0, 0
  addi x20, x0, 0
  addi x21, x0, 0
  addi x22, x0, 0
  addi x23, x0, 0
  addi x24, x0, 0
  addi x25, x0, 0
  addi x26, x0, 0
  addi x27, x0, 0
  addi x28, x0, 0
  addi x29, x0, 0
  addi x30, x0, 0
  addi x31, x0, 0

  /* set stack pointer */
  lui sp, %hi(4*1024)

  j fibonacci

fibonacci:
    lui x31, 0x80000
    addi x30, x0, 44
    addi x29, x0, 255

    addi x5, x0, 1
    addi x6, x0, 1
    
_loop_start_1:
    beq x29, x0, done
    add x7, x5, x6
    add x5, x6, x7
    add x6, x7, x5
    srli x29, x29, 1
    j _loop_start_1

done:
    j done
