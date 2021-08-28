module top (
  inout wire gpio_2,
  inout wire gpio_46,
  inout wire gpio_47,
  inout wire gpio_45,
  inout wire gpio_48,
  inout wire gpio_3,
  inout wire gpio_4,
  inout wire gpio_44
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
      gpio_48,
      gpio_3,
      gpio_4,
      gpio_44
    })
  );
endmodule
