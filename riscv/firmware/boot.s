  .section .init, "ax"
  .global _start
_start:
  li sp, 1000
  jal zero, main
