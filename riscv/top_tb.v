`timescale 1ns/1ps

module tb();
  localparam HALF_PERIOD = 30;
  localparam NUM_CYCLES = 256;

  initial begin
    $dumpfile("top_tb.vcd");
    $dumpvars(0, t);
  end

  reg clk = 1'b0;
  wire d0;
  wire d1;
  wire d2;
  wire d3;
  wire d4;
  wire d5;
  wire d6;
  wire d7;

  riscv t (
    .clk(clk),
    .d0(d0),
    .d1(d1),
    .d2(d2),
    .d3(d3)
  );

  always begin
    #HALF_PERIOD clk = !clk;
  end

  initial begin
    repeat(NUM_CYCLES) @(negedge clk);

    $finish;
  end
endmodule
