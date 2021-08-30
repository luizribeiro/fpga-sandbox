#ifndef __RISCV_H
#define __RISCV_H

extern unsigned char __iodev_begin;

// GPIO
#define GPIO (*(unsigned char *)&__iodev_begin)
#define GPIO_DIR (*((unsigned char *)&__iodev_begin + 0x1))
#define INPUT 0
#define OUTPUT 1
void set_pin_direction(int pin, int direction);

// UART
#define UART_TX (*((unsigned char *)&__iodev_begin + 0x2))
#define UART_STATUS (*((unsigned char *)&__iodev_begin + 0x3))
int is_uart_busy();
void uart_putc(char c);
void uart_puts(char *s);

#endif
