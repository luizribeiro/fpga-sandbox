MEMORY
{
  rom      (rx)  : ORIGIN = 0x00000000, LENGTH = 0x00040000
}

SECTIONS
{
    .text :
    {
    } > rom

    /DISCARD/ : {
      *(.comment)
      *(.riscv.attributes)
    }
}
