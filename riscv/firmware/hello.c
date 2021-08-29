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

void main(void) {
  for (;;)
    for (int i = 0; i < 256; i++)
      GPIO = i;
}
