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
    _sdata = .;
    *(.data*);
    _edata = .;
  } > ram AT > rom

  /DISCARD/ : {
    *(.comment)
    *(.riscv.attributes)
  }

  PROVIDE(__iodev_begin = ORIGIN(iodev));
  PROVIDE(__iodev_end = ORIGIN(iodev) + LENGTH(iodev));
}
