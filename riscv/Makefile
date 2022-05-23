.PHONY: all build clean firmware

all: build

build: hardware.bin

firmware:
	$(MAKE) -C firmware/ hello.mem

hardware.bin: memory.v riscv.v top.v firmware firmware/hello.mem
	apio build

upload: hardware.bin
	apio upload

clean:
	$(MAKE) -C firmware/ clean
	rm -f hardware.{asc,bin,json}
	rm -f top_tb.{vcd,out}
