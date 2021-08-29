`include "config.vh"
`include "instructions.vh"

module ram (
  input wire clk,
  input wire en,
  input wire [2:0] write_enable,
  input wire [31:0] addr,
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
  input wire [31:0] addr,
  output wire [31:0] data_out,
  output wire [31:0] inst
);
  reg [31:0] mem [`ROM_SIZE:0];
  assign data_out = en ? mem[addr[9:2]] : 'hzz;

  integer i;
  initial $readmemh("firmware/hello.mem", mem);

  assign inst = mem[iaddr >> 2];
endmodule

module iodev (
  input wire clk,
  input wire en,
  input wire [2:0] write_enable,
  input wire [31:0] addr,
  input wire [31:0] data_in,
  output wire [31:0] data_out,
  inout wire [`MAX_GPIO:0] gpio_port
);
  reg [`MAX_GPIO:0] r_gpio;
  reg [`MAX_GPIO:0] gpio_dir = {(`MAX_GPIO+1){1'b1}};

  assign data_out = en ? (
    addr[0]
    ? {{(32-`MAX_GPIO-1){1'b0}}, gpio_dir}
    : {{(32-`MAX_GPIO-1){1'b0}}, r_gpio}
  ) : 'hzz;

  generate
    genvar i;

    for (i = 0; i <= `MAX_GPIO; i = i+1) begin
      assign gpio_port[i] = gpio_dir[i] ? r_gpio[i] : 1'bz;

      always @(posedge clk) if (en) begin
        if (write_enable[2]) begin
          if (addr[0]) gpio_dir[i] <= data_in[i];
          else if (gpio_dir[i]) r_gpio[i] <= data_in[i];
        end else r_gpio[i] <= gpio_dir[i] ? r_gpio[i] : gpio_port[i];
      end
    end
  endgenerate
endmodule

module memory (
  input wire clk,
  input wire [31:0] iaddr,
  input wire [2:0] write_enable,
  input wire [31:0] addr,
  input wire [31:0] data_in,
  inout wire [`MAX_GPIO:0] gpio,
  output wire [31:0] data_out,
  output wire [31:0] inst
);
  rom rom (
    .clk(clk),
    // rom starts at 0x00000000
    .en(~(addr[31] | addr[30] | addr[29] | addr[28])),
    .addr(addr),
    .data_out(data_out),
    .iaddr(iaddr),
    .inst(inst)
  );

  ram ram (
    .clk(clk),
    // ram starts at 0x10000000
    .en(addr[28]),
    .write_enable(write_enable),
    .addr(addr),
    .data_in(data_in),
    .data_out(data_out)
  );

  iodev iodev (
    .clk(clk),
    // iodev starts at 0x20000000
    .en(addr[29]),
    .write_enable(write_enable),
    .addr(addr),
    .data_in(data_in),
    .data_out(data_out),
    .gpio_port(gpio)
  );
endmodule
