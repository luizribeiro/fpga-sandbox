module playground (
  output wire gpio_23,
  output wire gpio_25,
);
  wire clk;
  SB_HFOSC u_SB_HFOSC (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));

  localparam N = 5;
  reg [N:0] counter;
  wire gpio_23 = counter[N-1];
  wire gpio_25 = counter[N-2];

  always @(posedge clk) begin
    counter <= counter + 1'b1;
  end
endmodule
