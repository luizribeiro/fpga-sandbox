.PHONY: all clean dump docker-image
.SECONDARY:

SOURCES := $(shell find . -name '*.c')
HEADERS := $(shell find . -name '*.h')
OBJECTS := $(SOURCES:%.c=%.o)
ASM_OUTPUTS := $(SOURCES:%.c=%.s)

all: hello.elf hello.mem

ifneq ($(SKIP_DOCKER), true)
PWD := $(shell eval pwd)
WORKDIR := /work
DOCKER_CONTAINER := riscv-gnu-toolchain
DOCKER_RUN := docker run -tv $(PWD):$(WORKDIR) -w $(WORKDIR) $(DOCKER_CONTAINER)
endif

CC := riscv32-unknown-elf-gcc
CFLAGS := -march=rv32i -mabi=ilp32 -fno-common -fno-builtin-printf -Og
LDFLAGS := -static -T riscv.ld -nostdlib

%.s: %.c $(HEADERS)
	$(DOCKER_RUN) $(CC) $(CFLAGS) -S -o $@ -c $<

%.o: %.c
%.o: %.s
	$(DOCKER_RUN) $(CC) -o $@ -c $<

hello.elf: $(OBJECTS) boot.o riscv.ld
	$(DOCKER_RUN) $(CC) $(LDFLAGS) -o $@ hello.o riscv.o boot.o

hello.bin: hello.elf
	$(DOCKER_RUN) riscv32-unknown-elf-objcopy -O binary hello.elf hello.bin

hello.mem: hello.bin
	hexdump -ve '1/4 "%08x\n"' hello.bin > hello.mem

clean:
	rm -f $(ASM_OUTPUTS) $(OBJECTS) boot.o hello.elf hello.bin hello.mem

dump: hello.elf
	$(DOCKER_RUN) riscv32-unknown-elf-objdump -sdl hello.elf | less

docker-image:
	docker build -t $(DOCKER_CONTAINER) .
