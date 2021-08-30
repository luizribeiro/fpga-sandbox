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
