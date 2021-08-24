MEMORY
{
  rom      (rx)  : ORIGIN = 0x00000000, LENGTH = 0x800
  ram      (rwx) : ORIGIN = 0x10000000, LENGTH = 0x2000
  iodev    (w)   : ORIGIN = 0x20000000, LENGTH = 0x4
}

SECTIONS
{
  .text :
  {
    *(.init)
    *(.text)
  } > rom

  /* .data is placed in rom and copied to ram on boot */
  .data :
  {
    __ram_data_start = .;
    *(.data*);
    *(.sdata*);
    . = ALIGN(4);
    __ram_data_end = .;
  } > ram AT > rom
  __rom_data_start = LOADADDR(.data);

  /DISCARD/ : {
    *(.comment)
    *(.riscv.attributes)
  }

  PROVIDE(__ram_begin = ORIGIN(ram));
  PROVIDE(__initial_stack_pointer = ORIGIN(ram) + LENGTH(ram) - 1);
  PROVIDE(__ram_end = ORIGIN(ram) + LENGTH(ram));
  PROVIDE(__iodev_begin = ORIGIN(iodev));
  PROVIDE(__iodev_end = ORIGIN(iodev) + LENGTH(iodev));
}
