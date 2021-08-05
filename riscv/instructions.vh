// vim: set ft=verilog:
`ifndef __INSTRUCTIONS_H
`define __INSTRUCTIONS_H

// RV32I Base Instruction Set
`define LUI     7'b0110111
`define AUIPC   7'b0010111
`define JAL     7'b1101111
`define JALR    7'b1100111

//
`define BEQ     7'b1100011
`define BNE     7'b1100011
`define BLT     7'b1100011
`define BGE     7'b1100011
`define BLTU    7'b1100011
`define BGEU    7'b1100011

//
`define LB      7'b0000011
`define LH      7'b0000011
`define LW      7'b0000011
`define LBU     7'b0000011
`define LHU     7'b0000011

//
`define SB      7'b0100011
`define SH      7'b0100011
`define SW      7'b0100011

//
`define ADDI    7'b0010011
`define SLTI    7'b0010011
`define SLTIU   7'b0010011
`define XORI    7'b0010011
`define ORI     7'b0010011
`define ANDI    7'b0010011
`define SLLI    7'b0010011
`define SRLI    7'b0010011
`define SRAI    7'b0010011

//
`define ADD     7'b0110011
`define SUB     7'b0110011
`define SLL     7'b0110011
`define SLT     7'b0110011
`define SLTU    7'b0110011
`define XOR     7'b0110011
`define SRL     7'b0110011
`define SRA     7'b0110011
`define OR      7'b0110011
`define AND     7'b0110011

//
`define FENCE   7'b0001111

//
`define ECALL   7'b1110011
`define EBREAK  7'b1110011

`endif
