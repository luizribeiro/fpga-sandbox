#ifndef __RISCV_H
#define __RISCV_H

extern unsigned char __iodev_begin;

#define IODEV(addr) (*((unsigned char *)&__iodev_begin + addr))

// GPIO
#define GPIO IODEV(0x0)
#define GPIO_DIR IODEV(0x1)
#define INPUT 0
#define OUTPUT 1
void set_pin_direction(int pin, int direction);

// UART
#define UART_TX IODEV(0x2)
#define UART_STATUS IODEV(0x3)
int is_uart_busy();
void uart_putc(char c);
void uart_puts(char *s);

#endif
