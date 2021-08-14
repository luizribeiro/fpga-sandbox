`include "instructions.vh"

`define MEM_SIZE 2047

module ram (
  input wire clk,
  input wire [2:0] write_enable,
  input wire [31:0] addr,
  input wire [31:0] data_in,
  output wire [31:0] data_out
);
  reg [7:0] mem [`MEM_SIZE:0];
  integer i;

  initial begin
    for (i = 0; i <= `MEM_SIZE; i++)
      mem[i] = 8'b0;
  end

  always @(posedge clk) begin
    if (write_enable[0]) begin
      mem[addr] <= data_in[31:24];
      mem[addr + 1] <= data_in[23:16];
      mem[addr + 2] <= data_in[15:8];
      mem[addr + 3] <= data_in[7:0];
    end else if (write_enable[1]) begin
      mem[addr] <= data_in[15:8];
      mem[addr + 1] <= data_in[7:0];
    end else if (write_enable[2]) begin
      mem[addr] <= data_in[7:0];
    end
  end

  assign data_out = {mem[addr], mem[addr + 1], mem[addr + 2], mem[addr + 3]};
endmodule

module rom (
  input wire clk,
  input wire [31:0] addr,
  output wire [31:0] data
);
  reg [31:0] mem [1023:0];

  reg [31:0] rin;
  integer i, fd, cnt;
  initial begin
    for (i = 0; i <= 1023; i++)
      mem[i] = 32'b0;
    fd = $fopen("hello.bin", "rb");
    for (i = 0; !$feof(fd); i++) begin
      cnt = $fread(rin, fd);
      mem[i] = {rin[7:0], rin[15:8], rin[23:16], rin[31:24]};
    end
    $fclose(fd);
  end

  assign data = mem[addr];
endmodule
