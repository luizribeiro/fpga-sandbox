  .section .init, "ax"
  .global _start
_start:
  la sp, __initial_stack_pointer

  la a0, __ram_data_start
  la a1, __ram_data_end
  la a2, __rom_data_start
_copy_data:
  ble a1, a0, _copy_done
  lw a3, 0(a2)
  sw a3, 0(a0)
  addi a0, a0, 4
  addi a2, a2, 4
  j _copy_data
_copy_done:
  jal zero, main
