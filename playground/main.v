module main (
  output wire gpio_23,
  output wire gpio_25,
  output wire gpio_26
);
  wire clk;
  /* verilator lint_off PINMISSING */
  SB_HFOSC u_SB_HFOSC (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));
  playground p (.clk(clk), .a(gpio_23), .b(gpio_25));
  assign gpio_26 = clk;
endmodule

module playground (
  input wire clk,
  output wire a,
  output wire b
);
  localparam N = 3;
  reg [N:0] counter = 'b0;
  assign a = counter[N];
  assign b = counter[N-1];

  always @(posedge clk) begin
    counter <= counter + 1'b1;
  end
endmodule
