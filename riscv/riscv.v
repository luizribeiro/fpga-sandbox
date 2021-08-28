/* verilator lint_off CASEINCOMPLETE */
`include "config.vh"
`include "instructions.vh"

module riscv (
  input wire clk,
  inout wire [`MAX_GPIO:0] gpio
);
  reg [`WORD:0] regs [`LAST_REG:0];

  reg [`WORD:0] pc;
  wire [`WORD:0] inst;
  reg [6:0] opcode;
  reg [4:0] rd, rs1, rs2;
  reg [2:0] funct3;
  reg [6:0] funct7;
  reg [11:0] funct12, i_imm, s_imm;
  reg [12:0] b_imm;
  reg [19:0] u_imm;
  reg [20:0] j_imm;
  reg [4:0] shamt;

  reg [`WORD:0] a, b, alu_ans, branch_addr, mem_in;
  reg [2:0] mem_write;
  wire [`WORD:0] mem_out;
  memory memory (
    .clk(clk),
    .iaddr(pc),
    .inst(inst),
    .write_enable(mem_write),
    .addr(alu_ans),
    .data_in(mem_in),
    .data_out(mem_out),
    .gpio(gpio)
  );

  reg [4:0] stage;
  integer i;

  initial begin
    pc = 'h0;
    mem_write = 3'b0;
    stage = 5'b1;
    regs[0] = 'd0;
  end

  always @(posedge clk) begin
    stage <= stage[4] ? 5'b1 : stage << 1;

    // instruction fetch
    if (stage[0]) begin
      opcode <= inst[6:0];
      rd <= inst[11:7];
      rs1 <= inst[19:15];
      rs2 <= inst[24:20];
      funct3 <= inst[14:12];
      funct7 <= inst[31:25];
      funct12 <= inst[31:20];
      u_imm <= inst[31:12];
      i_imm <= inst[31:20];
      s_imm <= {inst[31:25], inst[11:7]};
      j_imm <= {inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
      b_imm <= {inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
      shamt <= inst[24:20];
    end

    // instruction decode
    if (stage[1]) begin
      case (opcode)
        `LUI: begin
          a <= {u_imm, 12'b0};
          b <= 'b0;
        end
        `AUIPC: begin
          a <= pc;
          b <= {u_imm, 12'b0};
        end
        `JAL: begin
          a <= pc;
          b <= $signed({{11{j_imm[20]}}, j_imm});
        end
        `JALR: begin
          a <= regs[rs1];
          b <= $signed({{20{i_imm[11]}}, i_imm});
        end
        `BRANCH: begin
          a <= regs[rs1];
          b <= regs[rs2];
          branch_addr <= pc + $signed({{19{b_imm[12]}}, b_imm});
        end
        `LOAD: begin
          a <= regs[rs1];
          b <= $signed({{20{i_imm[11]}}, i_imm});
        end
        `STORE: begin
          a <= regs[rs1];
          b <= $signed({{20{s_imm[11]}}, s_imm});
          mem_in <= regs[rs2];
        end
        `OP_IMM: begin
          case (funct3)
            `ADDI, `SLTI, `SLTIU, `XORI, `ORI, `ANDI: begin
              a <= {{20{i_imm[11]}}, i_imm[11:0]};
              b <= regs[rs1];
            end
            `SLLI, `SRXI: begin
              a <= regs[rs1];
              b <= {27'b0, shamt[4:0]};
            end
          endcase
        end
        `OP: begin
          a <= regs[rs1];
          b <= regs[rs2];
        end
      endcase
    end

    // execute
    if (stage[2]) begin
      case (opcode)
        `LUI, `AUIPC, `JAL, `JALR, `LOAD, `STORE: alu_ans <= a + b;
        `BRANCH: begin
          case (funct3)
            `BEQ: alu_ans <= {31'b0, a == b};
            `BNE: alu_ans <= {31'b0, a != b};
            `BLT: alu_ans <= {31'b0, $signed(a) < $signed(b)};
            `BGE: alu_ans <= {31'b0, $signed(a) >= $signed(b)};
            `BLTU: alu_ans <= {31'b0, a < b};
            `BGEU: alu_ans <= {31'b0, a >= b};
          endcase
        end
        `OP_IMM: begin
          case (funct3)
            `ADDI: alu_ans <= a + b;
            `SLTI: alu_ans <= {31'b0, $signed(a) > $signed(b)};
            `SLTIU: alu_ans <= {31'b0, a > b};
            `XORI: alu_ans <= a ^ b;
            `ORI: alu_ans <= a | b;
            `ANDI: alu_ans <= a & b;
            `SLLI: alu_ans <= a << b;
            `SRXI: alu_ans <= i_imm[10] ? a >>> b : a >> b;
          endcase
        end
        `OP: begin
          case (funct3)
            `ADD: alu_ans <= a + b;
            // TODO: implement SUB
            `SLL: alu_ans <= a << b;
            `SLT: alu_ans <= {31'b0, $signed(a) > $signed(b)};
            `SLTU: alu_ans <= {31'b0, a > b};
            `XOR: alu_ans <= a ^ b;
            `SRL: alu_ans <= a >> b;
            // TODO implement SRA
            `OR: alu_ans <= a | b;
            `AND: alu_ans <= a & b;
          endcase
        end
      endcase
    end

    // memory access
    if (stage[3]) begin
      case (opcode)
        `LOAD: mem_write <= 3'b0;
        `STORE: begin
          case (funct3)
            `SB: mem_write <= 3'b100;
            `SH: mem_write <= 3'b010;
            `SW: mem_write <= 3'b001;
            default: mem_write <= 3'b0;
          endcase
        end
      endcase
    end

    // write back
    if (stage[4]) begin
      if (rd != 5'b0) begin
        case (opcode)
          `JAL, `JALR: regs[rd] <= pc + 4;
          `AUIPC, `LUI: regs[rd] <= alu_ans;
          `LOAD: begin
            case (funct3)
              `LB: regs[rd] <= {{24{mem_out[7]}}, mem_out[7:0]};
              `LW: regs[rd] <= mem_out;
              `LBU: regs[rd] <= {24'b0, mem_out[7:0]};
              `LHU: regs[rd] <= {16'b0, mem_out[15:0]};
            endcase
          end
          `OP_IMM, `OP: regs[rd] <= alu_ans;
        endcase
      end

      case (opcode)
        `JAL, `JALR: pc <= alu_ans;
        `BRANCH: pc <= alu_ans[0] ? branch_addr : pc + 4;
        default: pc <= pc + 4;
      endcase

      mem_write <= 3'b0;
    end
  end
endmodule
