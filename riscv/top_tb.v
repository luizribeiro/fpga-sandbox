`timescale 1ns/1ps

module tb();
  localparam HALF_PERIOD = 30;
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
    for (i = 0; i < 1024; i++)
      cpu.prog.mem[i] = 32'b0;
    cpu.prog.mem[0] = {20'h1f, 5'd1, `LUI}; // lui x1, 0x1f
    cpu.prog.mem[1] = {20'hf1, 5'd2, `LUI}; // lui x2, 0xf1
    cpu.prog.mem[31] = {12'h00, 5'd0, 3'b0, 5'd0, `JALR}; // jalr x0, x0(0x00)

    repeat(NUM_CYCLES) @(negedge clk);

    $finish;
  end
endmodule
