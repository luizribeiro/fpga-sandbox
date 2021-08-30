#include "riscv.h"

void main(void) {
  char str[] = "Hello, world!\r\n";
  for (;;) {
    uart_puts(str);
    for (int i = 0; i < 650000; i++)
      ;
  }
}
