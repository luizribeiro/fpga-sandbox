#include "riscv.h"

void set_pin_direction(int pin, int direction) {
  if (pin < 0 || pin >= 8)
    return;

  if (direction == INPUT)
    GPIO_DIR &= ~(1 << pin);
  else if (direction == OUTPUT)
    GPIO_DIR |= (1 << pin);
}

int is_uart_busy() { return UART_STATUS & 1; }

void uart_putc(char c) {
  while (is_uart_busy())
    ;
  UART_TX = c;
}

void uart_puts(char *s) {
  for (char *p = s; *p; p++)
    uart_putc(*p);
}
