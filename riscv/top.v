`define NUM_BITS 8
`define N 8

module top (
  output wire gpio_2,
  output wire gpio_46,
  output wire gpio_47,
  output wire gpio_45,
  output wire gpio_28,
  output wire gpio_3,
  output wire gpio_4,
  output wire gpio_44
);
  wire clk;
  /* verilator lint_off PINMISSING */
  SB_HFOSC u_SB_HFOSC (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));

  riscv p (
    .clk(clk),
    .gpio({
      gpio_2,
      gpio_46,
      gpio_47,
      gpio_45,
      gpio_28,
      gpio_3,
      gpio_4,
      gpio_44
    })
  );
endmodule

module riscv (
  input wire clk,
  output wire [`NUM_BITS-1:0] gpio
);
  reg [`N:0] counter = 'b0;
  always @(posedge clk) begin
    counter <= counter + 1'b1;
  end

  assign gpio = counter[`N:`N-`NUM_BITS];
endmodule
