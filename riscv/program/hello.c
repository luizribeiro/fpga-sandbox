#define GPIO (*(unsigned char *)0xa0)

void main(void) {
  for (;;)
    for (int i = 0; i < 8; i++) {
      GPIO = ((unsigned char)(1 << i));
    }
}
