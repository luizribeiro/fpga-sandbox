  .section .init, "ax"
  .global _start
_start:
# device initialization
  la sp, __stack_top
  addi sp, sp, -4

# copy .data section from ROM into RAM
  la a0, __ram_data_start
  la a1, __ram_data_end
  la a2, __rom_data_start
_copy_data:
  ble a1, a0, _call_main
  lw a3, 0(a2)
  sw a3, 0(a0)
  addi a0, a0, 4
  addi a2, a2, 4
  j _copy_data

# call into main()
_call_main:
  sw ra, 12(sp)
  sw s0, 8(sp)
  addi s0, sp, 16
  call main

# infinite loop in case main() returns
_end:
  j _end
