/* verilator lint_off CASEINCOMPLETE */
`include "config.vh"
`include "instructions.vh"

module riscv (
  input wire clk,
  output wire [`MAX_GPIO:0] gpio
);
  reg [`WORD:0] regs [`LAST_REG:0];

  reg [`WORD:0] pc;
  reg [`WORD:0] inst;
  wire [`WORD:0] winst;
  wire [6:0] opcode;
  wire [4:0] rd;
  wire [4:0] rs1;
  wire [4:0] rs2;
  wire [2:0] funct3;
  wire [6:0] funct7;
  wire [11:0] funct12;
  wire [19:0] u_imm;
  wire [11:0] i_imm;
  wire [11:0] s_imm;
  wire [20:0] j_imm;
  rom prog (
    .clk(clk),
    .addr(pc),
    .data(winst)
  );

  // alu
  reg [`WORD:0] a;
  reg [`WORD:0] b;
  reg [`WORD:0] alu_ans;
  reg [7:0] dest;
  reg [`WORD:0] branch_addr;

  reg [`WORD:0] mem_addr;
  reg [`WORD:0] mem_val;
  wire [`WORD:0] wmem_val;
  reg [`WORD:0] mem_in;
  reg [2:0] mem_write;
  ram memory (
    .clk(clk),
    .write_enable(mem_write),
    .addr(mem_addr),
    .data_in(mem_in),
    .data_out(wmem_val)
  );

  // TODO: do something more useful with GPIO
  assign gpio = pc[7:0];
  assign opcode = inst[6:0];
  assign rd = inst[11:7];
  assign rs1 = inst[19:15];
  assign rs2 = inst[24:20];
  assign funct3 = inst[14:12];
  assign funct7 = inst[31:25];
  assign funct12 = inst[31:20];
  assign u_imm = inst[31:12];
  assign i_imm = inst[31:20];
  assign s_imm = {inst[31:25], inst[11:7]};
  assign j_imm = {inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};

  reg [31:0] stage;
  integer i;

  initial begin
    pc = 'h0;
    mem_write = 3'b0;
    mem_addr = 'h0;
    dest = 'hff;
    stage = 'b1;

    for (i = 0; i <= `LAST_REG; i++)
      regs[i] = 32'd0;
  end

  always @(posedge clk)
    stage <= stage[4] ? 'b1 : stage << 1;

  always @(posedge stage[0]) begin
    // instruction fetch
    inst <= winst;
    mem_val <= wmem_val;
  end

  always @(posedge stage[1]) begin
    // decode
    case (opcode)
      `LUI: begin
        a <= {u_imm, 12'b0};
        b <= 'b0;
        dest <= {3'b0, rd};
      end
      `AUIPC: begin
        a <= pc;
        b <= {u_imm, 12'b0};
        dest <= {3'b0, rd};
      end
      `JAL: begin
        a <= pc;
        b <= {11'b0, j_imm};
        dest <= {3'b0, rd};
      end
      `JALR: begin
        a <= regs[rs1];
        b <= $signed({{20{i_imm[11]}}, i_imm});
        dest <= {3'b0, rd};
      end
      `BRANCH: begin
        a <= regs[rs1];
        b <= regs[rs2];
        branch_addr = pc + $signed({{11{j_imm[20]}}, j_imm});
        dest <= 'hff;
      end
      `LOAD: begin
        a <= regs[rs1];
        b <= $signed({{20{i_imm[11]}}, i_imm});
        dest <= {3'b0, rd};
      end
      `STORE: begin
        a <= regs[rs1];
        b <= $signed({{20{s_imm[11]}}, s_imm});
        dest <= 'hff;
        mem_in <= regs[rs2];
      end
      /*
      `OP_IMM: begin
        case (funct3)
          `ADDI: begin
            a <= {{20{i_imm[11]}}, i_imm[11:0]};
            b <= regs[rs1];
            dest <= {3'b0, rd};
          end
          // `SLTI:
          // `SLTIU:
          // `ORI:
          // `ANDI:
          // `SLLI:
          // `SRLI:
          // `SRAI:
        endcase
      end
    */
    endcase
  end

  always @(posedge stage[2]) begin
    // execute
    case (opcode)
      // alu
      `LUI, `AUIPC, `JAL, `JALR, `LOAD, `STORE: alu_ans <= a + b;
      `BRANCH: begin
        case (funct3)
          `BEQ: alu_ans <= {31'b0, a == b};
          `BNE: alu_ans <= {31'b0, a != b};
          `BLT: alu_ans <= {31'b0, $signed(a) < $signed(b)};
          `BGE: alu_ans <= {31'b0, $signed(a) > $signed(b)};
          `BLTU: alu_ans <= {31'b0, a < b};
          `BGEU: alu_ans <= {31'b0, a > b};
        endcase
      end
      /*
      `OP_IMM: begin
        case (funct3)
          `ADDI: begin
            alu_ans <= a + b;
          end
        endcase
      end
    */
    endcase
  end

  always @(posedge stage[3]) begin
    // memory access
    case (opcode)
      `LOAD: mem_addr <= alu_ans;
      `STORE: mem_addr <= alu_ans;
    endcase
  end
  always @(posedge stage[3]) begin
    // memory access
    case (opcode)
      `STORE: begin
        case (funct3)
          `SB: mem_write <= 3'b100;
          `SH: mem_write <= 3'b010;
          `SW: mem_write <= 3'b001;
          default: mem_write <= 3'b0;
        endcase
      end
      default: mem_write <= 3'b0;
    endcase
  end

  always @(posedge stage[4]) begin
    // write back
    case (opcode)
      `JAL, `JALR: begin
        pc <= alu_ans;
        regs[dest[4:0]] <= alu_ans;
      end
      `AUIPC, `LUI: begin
        regs[dest[4:0]] <= alu_ans;
        pc <= pc + 1;
      end
      `BRANCH: pc <= alu_ans[0] ? branch_addr : pc + 1;
      `LOAD: begin
        case (funct3)
          `LB: regs[dest[4:0]] <= {{24{mem_val[7]}}, mem_val[7:0]};
          `LW: regs[dest[4:0]] <= mem_val;
          `LBU: regs[dest[4:0]] <= {24'b0, mem_val[7:0]};
          `LHU: regs[dest[4:0]] <= {16'b0, mem_val[15:0]};
        endcase
        pc <= pc + 1;
      end
      `STORE: begin
        // FIXME: without this, we use tons of LUTs. with it, we get a warning
        // during synthesis
        mem_write <= 3'b0;
        pc <= pc + 1;
      end
      /*
      `OP_IMM: begin
        case (funct3)
          `ADDI: begin
            regs[dest[4:0]] <= alu_ans;
          end
        endcase
        pc <= pc + 1;
      end
      */
      default: pc <= pc + 1;
    endcase
  end
endmodule
