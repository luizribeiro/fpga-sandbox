#define GPIO (*(unsigned char *)0xa0)

void main(void) {
  int a = 0, b = 1, c;
  for (;;) {
    c = a + b;
    GPIO = ((unsigned char)(c));
    a = b;
    b = c;
  }
}
