WORKDIR="/work"

.PHONY: all clean dump docker-image
.SECONDARY:

all: hello.elf hello.mem

%.s: %.c riscv.h
	docker run -v `pwd`:$(WORKDIR) riscv-gnu-toolchain \
		riscv32-unknown-elf-gcc \
		-march=rv32i -mabi=ilp32 \
		-fno-common -fno-builtin-printf -S -Og \
		-o $(WORKDIR)/$@ -c $(WORKDIR)/$<

%.o: %.c
%.o: %.s
	docker run -v `pwd`:$(WORKDIR) riscv-gnu-toolchain \
		riscv32-unknown-elf-gcc \
		-march=rv32i -mabi=ilp32 \
		-o $(WORKDIR)/$@ -c $(WORKDIR)/$<

hello.elf: hello.o riscv.o boot.o riscv.ld
	docker run -v `pwd`:$(WORKDIR) riscv-gnu-toolchain \
		riscv32-unknown-elf-gcc \
		-march=rv32i -mabi=ilp32 \
		-static -T riscv.ld \
		-nostdlib \
		-o $(WORKDIR)/$@ \
		$(WORKDIR)/hello.o \
		$(WORKDIR)/riscv.o \
		$(WORKDIR)/boot.O

hello.bin: hello.elf
	docker run -v `pwd`:$(WORKDIR) riscv-gnu-toolchain \
		riscv32-unknown-elf-objcopy -O binary \
		$(WORKDIR)/hello.elf \
		$(WORKDIR)/hello.bin

hello.mem: hello.bin
	hexdump -ve '1/4 "%08x\n"' hello.bin > hello.mem

clean:
	rm -f hello.s riscv.s *.o *.elf *.bin *.mem

dump: hello.elf
	docker run -v `pwd`:$(WORKDIR) riscv-gnu-toolchain \
		riscv32-unknown-elf-objdump -sdl $(WORKDIR)/hello.elf

docker-image:
	docker build -t riscv-gnu-toolchain .
