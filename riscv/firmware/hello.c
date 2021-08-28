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

int get_bit(int val, int pin) { return !!(val & (1 << pin)); }

void main(void) {
  set_pin_direction(7, OUTPUT);
  set_pin_direction(1, INPUT);
  set_pin_direction(0, OUTPUT);
  for (;;)
    for (int i = 0; i < 256; i++) {
      GPIO = get_bit(i, 4) | (get_bit(GPIO, 1) << 7);
    }
}
