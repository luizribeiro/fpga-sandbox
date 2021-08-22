`include "config.vh"
`include "instructions.vh"

// 4 KiB
`define MEM_SIZE 1023

module ram (
  input wire clk,
  input wire [2:0] write_enable,
  input wire [31:0] addr,
  input wire [31:0] data_in,
  output wire [`MAX_GPIO:0] gpio,
  output wire [31:0] data_out
);
  reg [31:0] mem [`MEM_SIZE:0];
  reg [31:0] out;
  integer i;

  wire [31:0] data = mem[addr[11:2]];
  reg [31:0] gpio_data;

  initial begin
    for (i = 0; i <= `MEM_SIZE; i++)
      mem[i] = 32'b0;
    gpio_data = 32'b0;
  end

  always @(posedge clk) begin
    out <= addr[1]
      ? (addr[0] ? (data >> 24) : (data >> 16))
      : (addr[0] ? (data >> 8) : data);

    if (write_enable[0]) begin
      mem[addr[11:2]] <= data_in;
    end else if (write_enable[1]) begin
      mem[addr[11:2]] <= addr[1]
        ? {data_in[15:0], data[15:0]}
        : {data[31:16], data_in[15:0]};
    end else if (write_enable[2]) begin
      if (addr == 'ha0) gpio_data <= data_in;
      else mem[addr[11:2]] <= addr[1]
        ? (
          addr[0]
          ? {data_in[7:0], data[23:0]}
          : {data[31:24], data[7:0], data[15:0]}
        )
        : (
          addr[0]
          ? {data[31:16], data_in[7:0], data[7:0]}
          : {data[31:8], data_in[7:0]}
        );
    end
  end

  assign gpio = gpio_data[7:0];
  assign data_out = out;
endmodule

module rom (
  input wire clk,
  input wire [31:0] addr,
  output wire [31:0] data
);
  reg [31:0] mem [255:0]; // 1 KiB

  integer i;
  initial $readmemh("program/hello.mem", mem);

  assign data = mem[addr >> 2];
endmodule
