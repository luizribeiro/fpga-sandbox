#include "riscv.h"

#define INPUT 0
#define OUTPUT 1

void set_pin_direction(int pin, int direction) {
  if (pin < 0 || pin >= 8)
    return;

  if (direction == INPUT)
    GPIO_DIR &= ~(1 << pin);
  else if (direction == OUTPUT)
    GPIO_DIR |= (1 << pin);
}

int is_uart_idle() { return UART_STATUS & 1; }

void main(void) {
  char str[] = "Hello, world!\r\n";
  for (;;) {
    for (char *p = str; *p; p++) {
      UART_TX = *p;
      while (is_uart_idle())
        ;
    }
    for (int i = 0; i < 650000; i++)
      ;
  }
}
