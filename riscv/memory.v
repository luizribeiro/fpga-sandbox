`include "config.vh"
`include "instructions.vh"

module ram (
  input wire clk,
  input wire en,
  input wire [2:0] write_enable,
  input wire [23:0] addr,
  input wire [31:0] data_in,
  output wire [31:0] data_out
);
  reg [31:0] mem [`RAM_SIZE:0];
  assign data_out = en
    ? (
      addr[1]
        ? (addr[0] ? (data >> 24) : (data >> 16))
        : (addr[0] ? (data >> 8) : data)
    ) : 'hzz;
  integer i;

  wire [31:0] data = mem[addr[12:2]];

  always @(posedge clk) if (en) begin
    if (write_enable[0]) begin
      mem[addr[12:2]] <= data_in;
    end else if (write_enable[1]) begin
      mem[addr[12:2]] <= addr[1]
        ? {data_in[15:0], data[15:0]}
        : {data[31:16], data_in[15:0]};
    end else if (write_enable[2]) begin
      mem[addr[12:2]] <= addr[1]
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
endmodule

module rom (
  input wire clk,
  input wire en,
  input wire [31:0] iaddr,
  input wire [23:0] addr,
  output wire [31:0] data_out,
  output wire [31:0] inst
);
  reg [31:0] mem [`ROM_SIZE:0];
  assign data_out = en ? mem[addr[9:2]] : 'hzz;

  integer i;
  initial $readmemh("firmware/hello.mem", mem);

  assign inst = mem[iaddr >> 2];
endmodule

module memory_controller (
  input wire clk,
  input wire [31:0] iaddr,
  input wire [2:0] write_enable,
  input wire [31:0] addr,
  input wire [31:0] data_in,
  inout wire [`LAST_GPIO:0] gpio,
  output wire uart_txd,
  output wire [31:0] data_out,
  output wire [31:0] inst
);
  wire en_rom;
  rom rom (
    .clk(clk),
    .en(en_rom),
    .addr(addr[23:0]),
    .data_out(data_out),
    .iaddr(iaddr),
    .inst(inst)
  );

  wire en_ram;
  ram ram (
    .clk(clk),
    .en(en_ram),
    .write_enable(write_enable),
    .addr(addr[23:0]),
    .data_in(data_in),
    .data_out(data_out)
  );

  wire en_iodev;
  iodev iodev (
    .clk(clk),
    .en(en_iodev),
    .write_enable(write_enable),
    .addr(addr[23:0]),
    .data_in(data_in),
    .data_out(data_out),
    .gpio_port(gpio),
    .uart_txd(uart_txd)
  );

  assign {en_rom, en_ram, en_iodev} = f_en(addr[31:28]);
  function [2:0] f_en(input [3:0] addr);
    casez (addr)
      4'b0000: f_en = 3'b100;
      4'b0001: f_en = 3'b010;
      4'b001?: f_en = 3'b001;
      default: f_en = 3'b000;
    endcase
  endfunction
endmodule
