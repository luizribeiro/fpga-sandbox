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
    cpu.prog.mem[2] = {7'h0, 5'h1, 5'h0, `SW, 5'h0, `STORE}; // sw x1, 0(x0)
    cpu.prog.mem[3] = {12'h0, 5'd0, `LW, 5'd3, `LOAD}; // lw x3, 0(x0)
    cpu.prog.mem[31] = {12'h00, 5'd0, 3'b0, 5'd0, `JALR}; // jalr x0, x0(0x00)

    `assert(cpu.stage == 'b00001, "Expected stage 1");
    `assert(cpu.pc == 'h00, "Expected PC=0 on stage 1");

    repeat(1 * CYCLES) @(negedge clk);
    `assert(cpu.stage == 'b00010, "Expected stage 2");
    `assert(cpu.pc == 'h00, "Expected PC=0 on stage 2");
    `assert(cpu.opcode == `LUI, "Expected LUI opcode @ PC=0x00");
    `assert(cpu.regs[1] == 'h00, "x1 should originally be 0x00");
    `assert(cpu.regs[2] == 'h00, "x2 should originally be 0x00");
    `assert(
      (cpu.memory.mem[0] == 'h00),
      "Memory address 0x00 should be initially set to 0x00"
    );

    repeat(4 * CYCLES) @(negedge clk);
    `assert(cpu.stage == 'b00001, "Expected stage 1");
    `assert(cpu.pc == 'h04, "Expected PC=0x04");
    `assert(
      (cpu.regs[1] == {20'h1f, 12'h00}),
      "x1's 20 upper bits should be loaded with 0x1f"
    );

    repeat(5 * CYCLES) @(negedge clk);
    `assert(cpu.stage == 'b00001, "Expected stage 1 again");
    `assert(cpu.pc == 'h08, "Expected PC=0x08");
    `assert(cpu.opcode == `LUI, "Expected LUI opcode @ PC=0x01");
    `assert(
      (cpu.regs[2] == {20'hf1, 12'h00}),
      "x2's 20 upper bits should be loaded with 0xf1"
    );

    repeat(5 * CYCLES) @(negedge clk);
    `assert(cpu.stage == 'b00001, "Expected stage 1 again");
    `assert(cpu.pc == 'h0c, "Expected PC=0x0C");
    `assert(cpu.opcode == `STORE, "Expected STORE opcode @ PC=0x02");
    `assert(
      (cpu.memory.mem[0] == {20'h1f, 12'h00}),
      "Memory address 0x00 should be loaded with x1's contents"
    );

    `assert(cpu.regs[3] == 32'h00, "Expected x3 to be initially set to 0x00");
    repeat(5 * CYCLES) @(negedge clk);
    `assert(cpu.stage == 'b00001, "Expected stage 1 again");
    `assert(cpu.pc == 'h10, "Expected PC=0x10");
    `assert(cpu.opcode == `LOAD, "Expected LOAD opcode @ PC=0x03");
    `assert(
      (cpu.regs[3] == {20'h1f, 12'h00}),
      "Expected x3 to have contents of memory @ 0x00"
    );

    repeat(27 * 5 * CYCLES) @(negedge clk);
    `assert(cpu.pc == 31*4, "Expected PC=124");
    `assert(cpu.opcode == 7'b0, "Expected nil opcode");

    repeat(5 * CYCLES) @(negedge clk);
    `assert(cpu.pc == 'h00, "Expected PC=0x00 after JALR");
    `assert(cpu.opcode == `JALR, "Expected JALR opcode");

    repeat(NUM_CYCLES) @(negedge clk);

    $finish;
  end
endmodule
