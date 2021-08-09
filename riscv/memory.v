`include "instructions.vh"

module ram (
  input wire clk,
  input wire [2:0] write_enable,
  input wire [31:0] addr,
  input wire [31:0] data_in,
  output wire [31:0] data_out
);
  reg [7:0] mem [4095:0];
  integer i;

  initial begin
    for (i = 0; i < 4096; i++)
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
  integer i;

  initial begin
    for (i = 0; i < 1023; i++)
      mem[i] = 32'b0;

    mem[0] = {20'h1f, 5'd1, `LUI}; // lui r0, 0x1f
    mem[1] = {20'hf1, 5'd2, `LUI}; // lui r1, 0xf1
    mem[31] = {12'h00, 5'h00, 3'b0, 5'd3, `JALR}; // jalr r2, (0x00 + 0x00)
  end

  assign data = mem[addr];
endmodule
