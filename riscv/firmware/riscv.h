#ifndef __RISCV_H
#define __RISCV_H

extern unsigned char __iodev_begin;
#define GPIO (*(unsigned char *)&__iodev_begin)
#define GPIO_DIR (*((unsigned char *)&__iodev_begin + 0x1))

#endif
