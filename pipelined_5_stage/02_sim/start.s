/*****************************************************************************/
/* This assembly script is used for initialization.
   A section is made "init" to be used in the linker script
   In order to have the start function "findable" for linker, the global
   keyword is added
/*****************************************************************************/
.global start

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
  /* Initialize stack pointer to the top of the stack (top of DMEM region) */
  lui sp, %hi(0x00006FFF)    /* Load upper 20 bits of stack top address */
  addi sp, sp, %lo(0x00006FFF) /* Add lower 12 bits to the stack pointer */

  /* call main */
  jal ra, main
  j end

  /* break - trap */
  ebreak

end:
  j end

# /* Define the top of the stack in data section */
# .section .stack
# _stack_top:
#     .word 0x00006FFF   /* Stack starts at 0x00006FFF */
