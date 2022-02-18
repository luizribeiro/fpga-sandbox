.PHONY: all clean dump
.SECONDARY:

SOURCES := $(shell find . -name '*.c')
HEADERS := $(shell find . -name '*.h')
OBJECTS := $(SOURCES:%.c=%.o)
ASM_OUTPUTS := $(SOURCES:%.c=%.s)

all: hello.elf hello.mem

CC := riscv32-none-elf-gcc
CFLAGS := -march=rv32i -mabi=ilp32 -fno-common -fno-builtin-printf -Og
LDFLAGS := -static -T riscv.ld -nostdlib

%.s: %.c $(HEADERS)
	$(CC) $(CFLAGS) -S -o $@ -c $<

%.o: %.c
%.o: %.s
	$(CC) -o $@ -c $<

hello.elf: $(OBJECTS) boot.o riscv.ld
	$(CC) $(LDFLAGS) -o $@ hello.o riscv.o boot.o

hello.bin: hello.elf
	riscv32-none-elf-objcopy -O binary hello.elf hello.bin

hello.mem: hello.bin
	hexdump -ve '1/4 "%08x\n"' hello.bin > hello.mem

clean:
	rm -f $(ASM_OUTPUTS) $(OBJECTS) boot.o hello.elf hello.bin hello.mem

dump: hello.elf
	riscv32-none-elf-objdump -sdl hello.elf | less
