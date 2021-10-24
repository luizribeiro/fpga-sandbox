module freq (
  output wire gpio_28,
);
  wire clkhf, clk, _lock;
  SB_HFOSC u_SB_HFOSC (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clkhf));
  pll pll(
    .clock_in(clkhf),
    .clock_out(clk),
    .locked(_lock)
  );

  assign gpio_28 = clk;
endmodule
