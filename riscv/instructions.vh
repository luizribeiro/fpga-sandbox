// vim: set ft=verilog:
`ifndef __INSTRUCTIONS_H
`define __INSTRUCTIONS_H

// RV32I Base Instruction Set
`define LUI      7'b0110111
`define AUIPC    7'b0010111
`define JAL      7'b1101111
`define JALR     7'b1100111

// BRANCH (funct3)
`define BRANCH   7'b1100011
`define BEQ      3'b000
`define BNE      3'b001
`define BLT      3'b100
`define BGE      3'b101
`define BLTU     3'b110
`define BGEU     3'b111

// LOAD (funct3)
`define LOAD     7'b0000011
`define LB       3'b000
`define LH       3'b001
`define LW       3'b010
`define LBU      3'b100
`define LHU      3'b101

// STORE (funct3)
`define STORE    7'b0100011
`define SB       3'b000
`define SH       3'b001
`define SW       3'b010

// OP_IMM (funct3)
`define OP_IMM   7'b0010011 
`define ADDI     3'b000
`define SLTI     3'b010
`define SLTIU    3'b011
`define XORI     3'b100
`define ORI      3'b110
`define ANDI     3'b111
`define SLLI     3'b001
`define SRXI     3'b101
// 0000000 shamt rs1 101 rd 0010011 SRLI
// 0100000 shamt rs1 101 rd 0010011 SRAI

// OP (funct3, funct7)
`define OP       7'b0110011
`define ADDSUB   3'b000
`define SLL      3'b001
`define SLT      3'b010
`define SLTU     3'b011
`define XOR      3'b100
`define SRX      3'b101
`define OR       3'b110
`define AND      3'b111
// 0000000 rs2 rs1 000 rd 0110011 ADD
// 0100000 rs2 rs1 000 rd 0110011 SUB
// 0000000 rs2 rs1 001 rd 0110011 SLL
// 0000000 rs2 rs1 010 rd 0110011 SLT
// 0000000 rs2 rs1 011 rd 0110011 SLTU
// 0000000 rs2 rs1 100 rd 0110011 XOR
// 0000000 rs2 rs1 101 rd 0110011 SRL
// 0100000 rs2 rs1 101 rd 0110011 SRA
// 0000000 rs2 rs1 110 rd 0110011 OR
// 0000000 rs2 rs1 111 rd 0110011 AND

// MISC-MEM (funct3)
`define MISC_MEM 7'b0001111
`define FENCE    3'b000

// SYSTEM (funct12)
`define SYSTEM   7'b1110011
`define ECALL    12'b0
`define EBREAK   12'b1

// ALU operations
`define ALU_ADD 4'b0000
`define ALU_SUB 4'b0001
`define ALU_XOR 4'b0010
`define ALU_OR 4'b0011
`define ALU_AND 4'b0100
`define ALU_SLL 4'b0101
`define ALU_SLTS 4'b0110
`define ALU_SLTU 4'b0111
`define ALU_SRL 4'b1000
`define ALU_SRA 4'b1001
`define ALU_BEQ 4'b1010
`define ALU_BNEQ 4'b1011
`define ALU_BLTS 4'b1100
`define ALU_BLTU 4'b1101
`define ALU_BGES 4'b1110
`define ALU_BGEU 4'b1111

`endif
