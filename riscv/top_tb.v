`timescale 1ns/1ps

`define assert(condition, message) \
  if (!(condition)) begin \
    $display("FAILED ASSERTION: ", message); \
    $finish(2); \
  end

module tb();
  localparam HALF_PERIOD = 30;
  localparam CYCLES = 1;
  localparam NUM_CYCLES = 256;

  initial begin
    $dumpfile("top_tb.vcd");
    $dumpvars(0, cpu);
  end

  reg clk = 1'b0;
  wire [7:0] gpio;

  riscv cpu (
    .clk(clk),
    .gpio(gpio)
  );

  always begin
    #HALF_PERIOD clk = !clk;
  end

  integer i;

  initial begin
    for (i = 0; i <= 1023; i++)
      cpu.prog.mem[i] = 32'b0;
    cpu.prog.mem[0] = {20'h1f, 5'd1, `LUI}; // lui x1, 0x1f
    cpu.prog.mem[1] = {20'hf1, 5'd2, `LUI}; // lui x2, 0xf1
    cpu.prog.mem[31] = {12'h00, 5'd0, 3'b0, 5'd0, `JALR}; // jalr x0, x0(0x00)

    `assert(cpu.stage == 'b00001, "Expected stage 1");
    `assert(cpu.pc == 'h00, "Expected PC=0 on stage 1");

    repeat(1 * CYCLES) @(negedge clk);
    `assert(cpu.stage == 'b00010, "Expected stage 2");
    `assert(cpu.pc == 'h00, "Expected PC=0 on stage 2");
    `assert(cpu.opcode == `LUI, "Expected LUI opcode @ PC=0x00");
    `assert(cpu.regs[1] == 'h00, "x1 should originally be 0x00");
    `assert(cpu.regs[2] == 'h00, "x2 should originally be 0x00");

    repeat(3 * CYCLES) @(negedge clk);
    `assert(cpu.stage == 'b10000, "Expected stage 5");
    `assert(cpu.pc == 'h01, "Expected PC=0x01 on stage 5");
    `assert(
      (cpu.regs[1] == {20'h1f, 12'h00}),
      "x1's 20 upper bits should be loaded with 0x1f"
    );

    repeat(5 * CYCLES) @(negedge clk);
    `assert(cpu.stage == 'b10000, "Expected stage 5 again");
    `assert(cpu.pc == 'h02, "Expected PC=0x01 on stage 5");
    `assert(cpu.opcode == `LUI, "Expected LUI opcode @ PC=0x01");
    `assert(
      (cpu.regs[2] == {20'hf1, 12'h00}),
      "x2's 20 upper bits should be loaded with 0xf1"
    );

    repeat(29 * 5 * CYCLES) @(negedge clk);
    `assert(cpu.pc == 31, "Expected PC=31 on stage 5");
    `assert(cpu.opcode == 7'b0, "Expected nil opcode");

    repeat(5 * CYCLES) @(negedge clk);
    `assert(cpu.pc == 'h00, "Expected PC=0x00 after JALR");
    `assert(cpu.opcode == `JALR, "Expected JALR opcode");

    repeat(NUM_CYCLES) @(negedge clk);

    $finish;
  end
endmodule
