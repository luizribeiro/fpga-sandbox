/* verilator lint_off CASEINCOMPLETE */
`include "config.vh"
`include "instructions.vh"

module riscv (
  input wire clk,
  inout wire [`MAX_GPIO:0] gpio
);
  reg [`WORD:0] regs [`LAST_REG:0];

  reg [`WORD:0] pc, next_pc;
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

  reg [`WORD:0] a, b, alu_ans, branch_addr, mem_addr, mem_in;
  reg [3:0] alu_op;
  reg should_branch;
  reg [2:0] mem_write;
  wire [`WORD:0] mem_out;
  memory memory (
    .clk(clk),
    .iaddr(pc),
    .inst(inst),
    .write_enable(mem_write),
    .addr(mem_addr),
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
      next_pc <= pc + 4;
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
          alu_op <= `ALU_ADD;
        end
        `AUIPC: begin
          a <= pc;
          b <= {u_imm, 12'b0};
          alu_op <= `ALU_ADD;
        end
        `JAL: begin
          a <= pc;
          b <= {{11{j_imm[20]}}, j_imm};
          alu_op <= `ALU_ADD;
        end
        `JALR: begin
          a <= regs[rs1];
          b <= {{20{i_imm[11]}}, i_imm};
          alu_op <= `ALU_ADD;
        end
        `BRANCH: begin
          a <= regs[rs1];
          b <= regs[rs2];
          branch_addr <= pc + $signed({{19{b_imm[12]}}, b_imm});
          case (funct3)
            `BEQ: alu_op <= `ALU_BEQ;
            `BNE: alu_op <= `ALU_BNEQ;
            `BLT: alu_op <= `ALU_BLTS;
            `BGE: alu_op <= `ALU_BGES;
            `BLTU: alu_op <= `ALU_BLTU;
            `BGEU: alu_op <= `ALU_BGEU;
          endcase
        end
        `LOAD: begin
          a <= regs[rs1];
          b <= {{20{i_imm[11]}}, i_imm};
          alu_op <= `ALU_ADD;
        end
        `STORE: begin
          a <= regs[rs1];
          b <= {{20{s_imm[11]}}, s_imm};
          alu_op <= `ALU_ADD;
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
          case (funct3)
            `ADDI: alu_op <= `ALU_ADD;
            `SLTI: alu_op <= `ALU_SLTS;
            `SLTIU: alu_op <= `ALU_SLTU;
            `XORI: alu_op <= `ALU_XOR;
            `ORI: alu_op <= `ALU_OR;
            `ANDI: alu_op <= `ALU_AND;
            `SLLI: alu_op <= `ALU_SLL;
            `SRXI: alu_op <= i_imm[10] ? `ALU_SRA : `ALU_SRL;
          endcase
        end
        `OP: begin
          a <= regs[rs1];
          b <= regs[rs2];
          case (funct3)
            `ADDSUB: alu_op <= i_imm[10] ? `ALU_SUB : `ALU_ADD;
            `SLL: alu_op <= `ALU_SLL;
            `SLT: alu_op <= `ALU_SLTS;
            `SLTU: alu_op <= `ALU_SLTU;
            `XOR: alu_op <= `ALU_XOR;
            `SRX: alu_op <= i_imm[10] ? `ALU_SRA : `ALU_SRL;
            `OR: alu_op <= `ALU_OR;
            `AND: alu_op <= `ALU_AND;
          endcase
        end
      endcase
    end

    // execute
    if (stage[2]) begin
      case (alu_op)
        `ALU_ADD: alu_ans <= a + b;
        `ALU_SUB: alu_ans <= a - b;
        `ALU_XOR: alu_ans <= a ^ b;
        `ALU_OR: alu_ans <= a | b;
        `ALU_AND: alu_ans <= a & b;
        `ALU_SLL: alu_ans <= a << b;
        `ALU_SLTS: alu_ans <= {31'b0, $signed(a) > $signed(b)};
        `ALU_SLTU: alu_ans <= {31'b0, a > b};
        `ALU_SRL: alu_ans <= a >> b;
        `ALU_SRA: alu_ans <= a >>> b;
        `ALU_BEQ: should_branch <= a == b;
        `ALU_BNEQ: should_branch <= a != b;
        `ALU_BLTS: should_branch <= $signed(a) < $signed(b);
        `ALU_BLTU: should_branch <= a < b;
        `ALU_BGES: should_branch <= $signed(a) >= $signed(b);
        `ALU_BGEU: should_branch <= a >= b;
      endcase
    end

    // memory access
    if (stage[3]) begin
      case (opcode)
        `LOAD: begin
          mem_addr <= alu_ans;
          mem_write <= 3'b0;
        end
        `STORE: begin
          mem_addr <= alu_ans;
          mem_in <= regs[rs2];
          case (funct3)
            `SB: mem_write <= 3'b100;
            `SH: mem_write <= 3'b010;
            `SW: mem_write <= 3'b001;
          endcase
        end
      endcase
    end else mem_write <= 3'b0;

    // write back
    if (stage[4]) begin
      if (rd != 5'b0) begin
        case (opcode)
          `JAL, `JALR: regs[rd] <= next_pc;
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
        `BRANCH: pc <= should_branch ? branch_addr : next_pc;
        default: pc <= next_pc;
      endcase
    end
  end
endmodule
