`include "config.vh"

module iodev (
  input wire clk,
  input wire en,
  input wire [2:0] write_enable,
  input wire [23:0] addr,
  input wire [31:0] data_in,
  output wire [31:0] data_out,
  inout wire [`LAST_GPIO:0] gpio_port,
  output wire uart_txd
);
  reg [`LAST_GPIO:0] r_gpio;
  reg [`LAST_GPIO:0] gpio_dir = {(`NUM_GPIO){1'b1}};

  wire uart_tx_busy;
  uart uart (
    .clk(clk),
    .en(en),
    .write_enable(write_enable),
    .addr(addr),
    .data_in(data_in),
    .uart_txd(uart_txd),
    .uart_tx_busy(uart_tx_busy)
  );

  assign data_out = f_out(en, addr[3:0]);
  function [31:0] f_out(input en, input [3:0] addr);
    if (en) begin
      casez (addr)
        4'h1: f_out = {{(32-`NUM_GPIO){1'b0}}, gpio_dir};
        4'h0: f_out = {{(32-`NUM_GPIO){1'b0}}, r_gpio};
        4'h3: f_out = {31'b0, uart_tx_busy};
        default: f_out = 'hzz;
      endcase
    end else f_out = 'hzz;
  endfunction

  generate
    genvar i;

    for (i = 0; i < `NUM_GPIO; i = i+1) begin
      assign gpio_port[i] = gpio_dir[i] ? r_gpio[i] : 1'bz;

      always @(posedge clk) if (en) begin
        if (write_enable[2]) begin
          if (addr[3:0] == 4'h1) gpio_dir[i] <= data_in[i];
          else if (addr[3:0] == 4'h0 && gpio_dir[i]) r_gpio[i] <= data_in[i];
        end else r_gpio[i] <= gpio_dir[i] ? r_gpio[i] : gpio_port[i];
      end
    end
  endgenerate
endmodule
