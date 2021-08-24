WORKDIR="/work"

.PHONY: all clean dump docker-image

all: hello.elf hello.mem

hello.s: hello.c
	docker run -v `pwd`:$(WORKDIR) riscv-gnu-toolchain \
		riscv32-unknown-elf-gcc \
		-march=rv32i -mabi=ilp32 \
		-fno-common -fno-builtin-printf -S -Og \
		-o $(WORKDIR)/hello.s $(WORKDIR)/hello.c

boot.o: boot.s
	docker run -v `pwd`:$(WORKDIR) riscv-gnu-toolchain \
		riscv32-unknown-elf-gcc \
		-march=rv32i -mabi=ilp32 \
		-c $(WORKDIR)/boot.s

hello.o: hello.s
	docker run -v `pwd`:$(WORKDIR) riscv-gnu-toolchain \
		riscv32-unknown-elf-gcc \
		-march=rv32i -mabi=ilp32 \
		-c $(WORKDIR)/hello.s

hello.elf: hello.o boot.o riscv.ld
	docker run -v `pwd`:$(WORKDIR) riscv-gnu-toolchain \
		riscv32-unknown-elf-gcc \
		-march=rv32i -mabi=ilp32 \
		-static -T riscv.ld \
		-nostdlib \
		-o $(WORKDIR)/hello.elf $(WORKDIR)/hello.o $(WORKDIR)/boot.o

hello.bin: hello.elf
	docker run -v `pwd`:$(WORKDIR) riscv-gnu-toolchain \
		riscv32-unknown-elf-objcopy -O binary \
		$(WORKDIR)/hello.elf \
		$(WORKDIR)/hello.bin

hello.mem: hello.bin
	hexdump -e '1/4 "%08x\n"' hello.bin > hello.mem

clean:
	rm -f hello.s hello.o hello.elf hello.bin hello.mem

dump: hello.elf
	docker run -v `pwd`:$(WORKDIR) riscv-gnu-toolchain \
		riscv32-unknown-elf-objdump -sdl $(WORKDIR)/hello.elf

docker-image:
	docker build -t riscv-gnu-toolchain .
