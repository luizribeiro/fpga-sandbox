#ifndef __RISCV_H
#define __RISCV_H

extern unsigned char __iodev_begin;
#define GPIO (*(unsigned char *)&__iodev_begin)

#endif
