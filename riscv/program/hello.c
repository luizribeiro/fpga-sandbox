#include "riscv.h"

void main(void) {
  for (;;) {
    for (int i = 0; i < 8; i++) {
      GPIO = 1 << i;
    }
    __asm("nop");
    __asm("nop");
    GPIO = 0;
  }
}
