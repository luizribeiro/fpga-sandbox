`include "config.vh"
`include "instructions.vh"

module riscv (
  input wire clk,
  output wire [`MAX_GPIO:0] gpio
);
  reg [`WORD:0] mem [1023:0]; // 4096 bytes
  reg [`WORD:0] regs [`LAST_REG:0];
  reg [`MAX_GPIO:0] gpio_regs;
  reg [`WORD:0] pc;

  reg [`WORD:0] cur;

  // common for all (or most) instructions
  wire [6:0] opcode = cur[6:0];
  wire [4:0] rd = cur[11:7];

  // U-type instructions
  wire [19:0] u_imm = cur[31:12];

  // I-type instructions
  wire [11:0] i_imm = cur[31:20];
  wire [4:0] rs1 = cur[19:15];
  wire [2:0] funct3 = cur[14:12];

  // R-type instructions
  wire [6:0] funct7 = cur[31:25];
  wire [4:0] rs2 = cur[24:20];

  // S-type instructions
  wire [11:0] s_imm = {cur[31:25], cur[11:7]};

  // J-type instructions
  wire signed [20:0] j_imm = {cur[31], cur[19:12], cur[20], cur[30:21], 1'b0};

  integer step;
  integer i;

  initial begin
    pc = 0;
    step = 0;

    for (i = 0; i <= 1023; i = i + 1) mem[i] = 'b0;
    mem[0] = {20'h1f, 5'd0, `LUI}; // lui r0, 0x1f
    mem[1] = {20'hf1, 5'd1, `LUI}; // lui r1, 0xf1
    mem[32] = {12'h00, 5'h00, 3'b0, 5'd2, `JALR}; // jalr r2, (0x00 + 0x00)
  end

  //assign gpio = gpio_regs;
  assign gpio = pc[7:0];
  //assign gpio = regs[0][19:12];

  always @(posedge clk) begin
    // fetch
    if (step == 0) begin
      cur <= mem[pc];
      step <= step + 1;
    end

    // execute
    if (step == 1) begin
      case (opcode)
        `LUI: regs[rd] <= {u_imm, 12'b0};
        `AUIPC: regs[rd] <= pc + {u_imm, 12'b0};
        `JAL: begin
          pc <= pc + j_imm - 1; // -1 because it will get incremented on the next step
          regs[rd] <= (pc + j_imm) + 1; // uhmm this is supposedly + 4
        end
        `JALR: begin
          pc <= regs[rs1] + $signed(i_imm) - 1;
          regs[rd] <= (regs[rs1] + $signed(i_imm)) + 1; // +4?
        end
        /*
        `BEQ:
        `BNE:
        `BLT:
        `BGE:
        `BLTU:
        `BGEU:
        `LB:
        `LH:
        `LW:
        `LBU:
        `LHU:
        `SB:
        `SH:
        `SW:
        `ADDI:
        `SLTI:
        `SLTIU:
        `XORI:
        `ORI:
        `ANDI:
        `SLLI:
        `SRLI:
        `SRAI:
        `ADD:
        `SUB:
        `SLL:
        `SLT:
        `SLTU:
        `XOR:
        `SRL:
        `SRA:
        `OR:
        `AND:
        `FENCE:
        `ECALL:
        `EBREAK:
        */
      endcase
      step <= step + 1;
    end

    // finish (not sure if I need?)
    if (step == 2) begin
      pc <= pc + 'b1;
      step <= 0;
    end
  end
endmodule
