#include "riscv.h"

void main(void) {
  for (;;) {
    GPIO = 1;
    for (int i = 0; i < 8; i++) {
      GPIO = GPIO << i;
    }
    __asm("nop");
    __asm("nop");
    GPIO = 0;
  }
}
