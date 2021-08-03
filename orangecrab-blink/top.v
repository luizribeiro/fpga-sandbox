`default_nettype none

module top (
  input clk48,
  output rgb_led0_r,
  output rgb_led0_g,
  output rgb_led0_b
);
  reg [26:0] counter = 0;

  always @(posedge clk48) begin
    counter <= counter + 1;
  end

  assign rgb_led0_r = ~counter[24];
  assign rgb_led0_g = ~counter[25];
  assign rgb_led0_b = 1;
endmodule
