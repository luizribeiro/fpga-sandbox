module rgb_blink (
  output wire led_red,
  output wire led_blue,
  output wire led_green,
);
  wire clk;
  SB_HFOSC u_SB_HFOSC (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));

  localparam N = 27;
  reg [N:0] counter;
  wire a = counter[N-3];
  wire b = counter[N-4];

  always @(posedge clk) begin
    counter <= counter + 1'b1;
  end

  SB_RGBA_DRV rgb_driver (
    .RGBLEDEN(1'b1),
    .RGB0PWM(a & b),
    .RGB1PWM(a & ~b),
    .RGB2PWM(~a & b),
    .CURREN(1'b1),
    .RGB0(led_green),
    .RGB1(led_blue),
    .RGB2(led_red),
  );

  defparam rgb_driver.RGB0_CURRENT = "0b000001";
  defparam rgb_driver.RGB1_CURRENT = "0b000001";
  defparam rgb_driver.RGB2_CURRENT = "0b000001";
endmodule
