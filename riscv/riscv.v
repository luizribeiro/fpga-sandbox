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
  wire [6:0] opcode = inst[6:0];
  wire [4:0] rd = inst[11:7];
  wire [4:0] rs1 = inst[19:15];
  wire [4:0] rs2 = inst[24:20];
  wire [2:0] funct3 = inst[14:12];
  wire [6:0] funct7 = inst[31:25];
  wire [11:0] funct12 = inst[31:20];
  wire [19:0] u_imm = inst[31:12];
  wire [11:0] i_imm = inst[31:20];
  wire [11:0] s_imm = {inst[31:25], inst[11:7]};
  wire [20:0] j_imm = {inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
  rom prog (
    .clk(clk),
    .addr(pc),
    .data(inst)
  );

  reg [`WORD:0] mem_addr;
  reg [`WORD:0] mem_val;
  reg [`WORD:0] mem_in;
  reg [2:0] mem_write;
  ram memory (
    .clk(clk),
    .write_enable(mem_write),
    .addr(mem_addr),
    .data_in(res),
    .data_out(mem_val)
  );

  // alu
  reg [`WORD:0] a;
  reg [`WORD:0] b;
  reg [`WORD:0] res;
  reg [7:0] dest;
  reg [`WORD:0] branch_addr;

  // TODO: do something more useful with GPIO
  assign gpio = pc[7:0];

  reg [31:0] stage;

  initial begin
    pc = 'h0;
    mem_write = 3'b0;
    mem_addr = 'h0;
    dest = 'hff;
    stage = 'b1;
  end

  always @(posedge clk) begin
    // instruction fetch
    if (stage[0]) begin
    end

    // decode
    if (stage[1]) begin
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
          mem_write <= 3'b0;
        end
        `STORE: begin
          a <= regs[rs1];
          b <= $signed({{20{s_imm[11]}}, s_imm});
          dest <= 'hff;
          mem_in <= regs[rs2];
        end
        `OP_IMM: begin
          case (funct3)
            `ADDI: begin
              a <= {{20{i_imm[11]}}, i_imm[11:0]};
              b <= regs[rs1];
              dest <= {3'b0, rd};
            end
            // `SLTI:
            // `SLTIU:
            /*
            `ORI:
            `ANDI:
            `SLLI:
            `SRLI:
            `SRAI:
            */
          endcase
        end
      endcase
    end

    // execute
    if (stage[2]) begin
      case (opcode)
        // alu
        `LUI, `AUIPC, `JAL: res <= a + b;
        `BRANCH: begin
          case (funct3)
            `BEQ: res <= {31'b0, a == b};
            `BNE: res <= {31'b0, a != b};
            `BLT: res <= {31'b0, $signed(a) < $signed(b)};
            `BGE: res <= {31'b0, $signed(a) > $signed(b)};
            `BLTU: res <= {31'b0, a < b};
            `BGEU: res <= {31'b0, a > b};
          endcase
        end
        `LOAD: begin
          mem_addr <= a + b;
          mem_write <= 3'b0;
        end
        `STORE: begin
          mem_addr <= a + b;
          case (funct3)
            `SB: begin
              res <= {24'b0, mem_val[7:0]};
              mem_write <= 3'b100;
            end
            `SH: begin
              res <= {16'b0, mem_val[15:8], mem_val[7:0]};
              mem_write <= 3'b010;
            end
            `SW: begin
              res <= mem_val;
              mem_write <= 3'b001;
            end
          endcase
        end
        `OP_IMM: begin
          case (funct3)
            `ADDI: begin
              res <= a + b;
            end
          endcase
        end
      endcase
    end

    // memory access
    if (stage[3]) begin
      case (opcode)
        `LOAD: begin
          case (funct3)
            `LB: res <= {{24{mem_val[7]}}, mem_val[7:0]};
            `LH: res <= {{16{mem_val[15]}}, mem_val[15:0]};
            `LW: res <= mem_val;
            `LBU: res <= {24'b0, mem_val[7:0]};
            `LHU: res <= {16'b0, mem_val[15:0]};
          endcase
        end
      endcase
    end

    // write back
    if (stage[4]) begin
      stage <= 'b1;

      case (opcode)
        `JAL, `JALR: begin
          pc <= res;
          regs[dest[4:0]] <= res;
        end
        `AUIPC, `LUI: begin
          regs[dest[4:0]] <= res;
          pc <= pc + 1;
        end
        `BRANCH: pc <= res[0] ? branch_addr : pc + 1;
        `LOAD: begin
          regs[dest[4:0]] <= res;
          pc <= pc + 1;
        end
        `STORE: begin
          mem_write <= 3'b0;
          pc <= pc + 1;
        end
        `OP_IMM: begin
          case (funct3)
            `ADDI: begin
              regs[dest[4:0]] <= res;
            end
          endcase
          pc <= pc + 1;
        end
      endcase
    end else stage <= stage << 1;
  end
endmodule
