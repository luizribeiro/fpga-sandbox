  .section .init, "ax"
  .global _start
_start:
  lw sp, __initial_stack_pointer
  jal zero, main
