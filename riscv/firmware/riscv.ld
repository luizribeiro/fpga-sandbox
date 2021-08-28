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
    *(.boot)
    *(.text)
  } > rom

  .bss (NOLOAD) :
  {
    *(.bss*)
    . = ALIGN(4);
  } > ram

  /* .data is placed in rom and copied to ram on boot */
  .data :
  {
    __global_pointer$ = . + 0x800;
    __ram_data_start = .;
    *(.data*);
    *(.sdata*);
    . = ALIGN(4);
    __ram_data_end = .;
  } > ram AT > rom
  _edata = .; PROVIDE (edata = .);
  __rom_data_start = LOADADDR(.data);

  _end = .;

  /DISCARD/ : {
    *(.comment)
    *(.riscv.attributes)
  }

  PROVIDE(__ram_begin = ORIGIN(ram));
  PROVIDE(__stack_top = ORIGIN(ram) + LENGTH(ram));
  PROVIDE(__ram_end = ORIGIN(ram) + LENGTH(ram));
  PROVIDE(__iodev_begin = ORIGIN(iodev));
  PROVIDE(__iodev_end = ORIGIN(iodev) + LENGTH(iodev));
}
