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
    .d0(gpio_2),
    .d1(gpio_46),
    .d2(gpio_47),
    .d3(gpio_45),
    .d4(gpio_28),
    .d5(gpio_3),
    .d6(gpio_4),
    .d7(gpio_44)
  );
endmodule

module riscv (
  input wire clk,
  output wire d0,
  output wire d1,
  output wire d2,
  output wire d3,
  output wire d4,
  output wire d5,
  output wire d6,
  output wire d7
);
  localparam N = 11;

  reg [N:0] counter = 'b0;
  always @(posedge clk) begin
    counter <= counter + 1'b1;
  end

  assign d0 = counter[3];
  assign d1 = counter[4];
  assign d2 = counter[5];
  assign d3 = counter[6];
  assign d4 = counter[7];
  assign d5 = counter[8];
  assign d6 = counter[9];
  assign d7 = counter[10];
endmodule
