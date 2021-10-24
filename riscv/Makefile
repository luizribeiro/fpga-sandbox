.PHONY: all build clean firmware

all: build

build: hardware.bin

firmware:
	$(MAKE) -C firmware/ hello.mem

hardware.bin: memory.v riscv.v top.v firmware firmware/hello.mem
	-rm hardware.bin hardware.asc hardware.json
	apio build

upload: hardware.bin
	apio upload

clean:
	$(MAKE) -C firmware/ clean
	rm hardware.{asc,bin,json}
