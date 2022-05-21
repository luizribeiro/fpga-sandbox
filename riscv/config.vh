// vim: set ft=verilog:
`ifndef __CONFIG_H
`define __CONFIG_H

`define NUM_GPIO 8

`define WORD 31

`define LAST_REG 31

// 8 KiB of RAM (2048 words)
`define RAM_SIZE 2047
// 1 KiB of ROM (256 words)
`define ROM_SIZE 255

// convenience macros
`define LAST_GPIO `NUM_GPIO-1

`endif
