#include "riscv.h"

char str[] = "Hello, world!\r\n";

void main(void) {
  for (;;) {
    uart_puts(str);
    for (int i = 0; i < 650000; i++)
      ;
  }
}
