#ifndef __RISCV_H
#define __RISCV_H

extern unsigned char __iodev_begin;
#define GPIO (*(unsigned char *)&__iodev_begin)
#define GPIO_DIR (*((unsigned char *)&__iodev_begin + 0x1))
#define UART_TX (*((unsigned char *)&__iodev_begin + 0x2))
#define UART_STATUS (*((unsigned char *)&__iodev_begin + 0x3))

#define INPUT 0
#define OUTPUT 1

void set_pin_direction(int pin, int direction);
int is_uart_busy();

#endif
