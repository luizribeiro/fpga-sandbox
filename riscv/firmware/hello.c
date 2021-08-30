#include "riscv.h"

void main(void) {
  char str[] = "Hello, world!\r\n";
  for (;;) {
    for (char *p = str; *p; p++) {
      UART_TX = *p;
      while (is_uart_busy())
        ;
    }
    for (int i = 0; i < 650000; i++)
      ;
  }
}
