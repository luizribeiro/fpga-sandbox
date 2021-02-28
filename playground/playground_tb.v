`timescale 1ns/1ps

module tb();
  localparam HALF_PERIOD = 30;
  localparam NUM_CYCLES = 16;

  initial begin
    $dumpfile("playground_tb.vcd");
    $dumpvars(0, t);
  end

  reg clk = 1'b0;
  wire a;
  wire b;

  playground t (.clk(clk), .a(a), .b(b));

  always begin
    #HALF_PERIOD clk = !clk;
  end

  initial begin
    repeat(NUM_CYCLES) @(negedge clk);

    $finish;
  end
endmodule
