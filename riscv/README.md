# fpga-sandbox/riscv

A stupid and simple RISC-V soft core, tested only on ice40up5k.

## Setup

First setup the docker image with the RISC-V toolchain:

```
cd firmware && make docker-image
```

## Build

Now build `hello.mem` with `make` from under `firmware/`.

And then from within `./`, upload everything to the FPGA:

```
apio build && apio upload
```

## Iterating

```
rm hardware.* ; (cd firmware && make) ; apio build && apio upload
```
