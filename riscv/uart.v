`define IDLE 3'd0
`define START_BIT 3'd1
`define DATA_BIT 3'd2
`define STOP_BIT 3'd3
`define DONE 3'd4

module uart (
  input wire clk,
  input wire en,
  input wire [2:0] write_enable,
  input wire [23:0] addr,
  input wire [31:0] data_in,
  output wire uart_txd,
  output wire uart_tx_busy
);
  reg [29:0] uart_cnt = 30'b0;
  always @(posedge clk) uart_cnt = uart_cnt + 53687;
  wire uart_clk = uart_cnt[27];
  reg signed [2:0] bits_left;
  reg tx_busy;
  reg [2:0] tx_state;
  reg [7:0] tx_data;
  reg tx_line = 1'b1;
  assign uart_txd = tx_line;
  assign uart_tx_busy = tx_state != `IDLE | tx_busy;

  initial begin
    tx_data = 8'b0;
    tx_busy = 1'b0;
    tx_state = `IDLE;
  end

  generate
    genvar j;
    for (j = 0; j < 8; j = j + 1)
      always @(posedge clk)
        if (en && write_enable[2] && addr[3:0] == 4'h2)
          tx_data[j] <= data_in[7 - j];
  endgenerate

  always @(posedge clk) begin
    if (en && write_enable[2] && addr[3:0] == 4'h2)
      tx_busy <= 1'b1;
    if (tx_state == `DONE)
      tx_busy <= 1'b0;
  end

  always @(posedge uart_clk) begin
    if (~tx_busy) tx_state <= `IDLE;
    case (tx_state)
      `IDLE: begin
        tx_line <= 1'b1;
        tx_state <= tx_busy ? `START_BIT : `IDLE;
      end
      `START_BIT: begin
        tx_line <= 1'b0;
        tx_state <= `DATA_BIT;
        bits_left <= 3'd7;
      end
      `DATA_BIT: begin
        tx_line <= tx_data[bits_left];
        tx_state <= bits_left == 3'b0 ? `STOP_BIT : `DATA_BIT;
        bits_left <= bits_left - 3'b1;
      end
      `STOP_BIT: begin
        tx_line <= 1'b1;
        tx_state <= `DONE;
      end
      default: tx_line <= 1'b1;
    endcase
  end
endmodule
