`include "config.vh"
`include "instructions.vh"

module riscv (
  input wire clk,
  output wire [`MAX_GPIO:0] gpio
);
  reg [7:0] mem [4095:0]; // 4096 bytes
  reg [`WORD:0] regs [`LAST_REG:0];
  reg [`MAX_GPIO:0] gpio_regs;
  reg [`WORD:0] pc;
  reg [`WORD:0] next_pc;

  reg [`WORD:0] cur;
  reg [`WORD:0] mem_val;

  // common for all (or most) instructions
  wire [6:0] opcode = cur[6:0];
  wire [4:0] rd = cur[11:7];

  // U-type instructions
  wire [19:0] u_imm = cur[31:12];

  // I-type instructions
  wire [11:0] i_imm = cur[31:20];
  wire [4:0] rs1 = cur[19:15];
  wire [2:0] funct3 = cur[14:12];
  wire [11:0] funct12 = cur[31:20];

  // R-type instructions
  wire [6:0] funct7 = cur[31:25];
  wire [4:0] rs2 = cur[24:20];

  // S-type instructions
  wire [11:0] s_imm = {cur[31:25], cur[11:7]};

  // J-type instructions
  wire signed [20:0] j_imm = {cur[31], cur[19:12], cur[20], cur[30:21], 1'b0};

  integer stage;
  integer i;
  integer j;

  task set_memory;
    input integer address;
    input reg[`WORD:0] value;
    begin
      for(j = 0; j < 4; j++)
        mem[4*address + j] = value[31-j*8:24-j*8];
    end
  endtask

  initial begin
    pc = 0;
    stage = 0;

    set_memory(0, {20'h1f, 5'd0, `LUI}); // lui r0, 0x1f
    set_memory(1, {20'hf1, 5'd1, `LUI}); // lui r1, 0xf1
    set_memory(32, {12'h00, 5'h00, 3'b0, 5'd2, `JALR}); // jalr r2, (0x00 + 0x00)
  end

  //assign gpio = gpio_regs;
  assign gpio = pc[9:2];
  //assign gpio = regs[0][19:12];

  always @(posedge clk) begin
    // fetch
    if (stage == 0) begin
      next_pc <= pc + 4;
      cur <= {mem[pc], mem[pc+1], mem[pc+2], mem[pc+3]};
      stage <= stage + 1;
    end

    // decode (actually just memory access rn)
    if (stage == 1) begin
      if (opcode == `LOAD)
        mem_val <= {
          mem[regs[rs1] + $signed(i_imm)],
          mem[regs[rs1] + $signed(i_imm) + 1],
          mem[regs[rs1] + $signed(i_imm) + 2],
          mem[regs[rs1] + $signed(i_imm) + 3]
        };
      stage <= stage + 1;
    end

    // execute
    if (stage == 2) begin
      case (opcode)
        `LUI: regs[rd] <= {u_imm, 12'b0};
        `AUIPC: regs[rd] <= pc + {u_imm, 12'b0};
        `JAL: begin
          next_pc <= pc + j_imm;
          regs[rd] <= pc + j_imm;
        end
        `JALR: begin
          next_pc <= regs[rs1] + $signed(i_imm);
          regs[rd] <= (regs[rs1] + $signed(i_imm));
        end
        `BRANCH: begin
          case (funct3)
            `BEQ: next_pc <= (regs[rs1] == regs[rs2]
              ? pc + $signed(j_imm) : next_pc);
            `BNE: next_pc <= (regs[rs1] != regs[rs2]
              ? pc + $signed(j_imm) : next_pc);
            `BLT: next_pc <= ($signed(regs[rs1]) < $signed(regs[rs2])
              ? pc + $signed(j_imm) : next_pc);
            `BGE: next_pc <= ($signed(regs[rs1]) > $signed(regs[rs2])
              ? pc + $signed(j_imm) : next_pc);
            `BLTU: next_pc <= (regs[rs1] < regs[rs2]
              ? pc + $signed(j_imm) : next_pc);
            `BGEU: next_pc <= (regs[rs1] > regs[rs2] ?
              pc + $signed(j_imm) : next_pc);
          endcase
        end
        `LOAD: begin
          case (funct3)
            `LB: regs[rd] = {{24{mem_val[7]}}, mem_val[7:0]};
            `LH: regs[rd] = {{16{mem_val[15]}}, mem_val[15:0]};
            `LW: regs[rd] = mem_val;
            `LBU: regs[rd] = {24'b0, mem_val[7:0]};
            `LHU: regs[rd] = {16'b0, mem_val[15:0]};
          endcase
        end
        `STORE: begin
          case (funct3)
            /*
            `SB:
            `SH:
            `SW:
            */
          endcase
        end
        `OP_IMM: begin
          case (funct3)
            /*
            `ADDI:
            `SLTI:
            `SLTIU:
            `XORI:
            `ORI:
            `ANDI:
            `SLLI:
            `SRLI:
            `SRAI:
            */
          endcase
        end
        `OP: begin
          /*
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
          */
        end
        `MISC_MEM: begin
          case (funct3)
            /*
            `FENCE:
            */
          endcase
        end
        `SYSTEM: begin
          case (funct12)
            /*
            `ECALL:
            `EBREAK:
            */
          endcase
        end
      endcase
      stage <= stage + 1;
    end

    // finish (not sure if I need?)
    if (stage == 3) begin
      pc <= next_pc;
      stage <= 0;
    end
  end
endmodule
