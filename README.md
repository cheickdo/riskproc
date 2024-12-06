# riskproc
Implementation of a byte addressable RV32I, RV32M compliant RISC-V processor in Verilog

The implementation currently only supports machine mode execution

## Table1. Instruction set


|Instruction|Opcode     |funct3 |funct7|
|-----------|-----------|-------|------|
|add        |0110011    |0x0    |0x00  |
|sub        |0110011    |0x0    |0x20  |
|xor        |0110011    |0x4    |0x00  |
|or         |0110011    |0x6    |0x00  |
|and        |0110011    |0x7    |0x00  |
|sll        |0110011    |0x1    |0x00  |
|srl        |0110011    |0x5    |0x00  |
|sra        |0110011    |0x5    |0x20  |
|slt        |0110011    |0x2    |0x00  |
|sltu       |0110011    |0x3    |0x00  |
|addi       |0010011    |0x0    |      |
|xori       |0010011    |0x4    |      |
|ori        |0010011    |0x6    |      |
|andi       |0010011    |0x7    |      |
|slli       |0010011    |0x1    |0x00  |
|srli       |0010011    |0x5    |0x00  |
|srai       |0010011    |0x5    |0x20  |
|sltiu      |0010011    |0x2    |      |
|sltiu      |0010011    |0x3    |      |
|lb         |0000011    |0x0    |      |
|lh         |0000011    |0x1    |      |
|lw         |0000011    |0x2    |      |
|lbu        |0000011    |0x4    |      |
|lhu        |0000011    |0x5    |      |
|sb         |0100011    |0x0    |      |
|sh         |0100011    |0x1    |      |
|sw         |0100011    |0x2    |      |
|beq        |1100011    |0x0    |      |
|bne        |1100011    |0x1    |      |
|blt        |1100011    |0x4    |      |
|bge        |1100011    |0x5    |      |
|bltu       |1100011    |0x6    |      |
|bgeu       |1100011    |0x7    |      |
|jal        |1101111    |0x0    |      |
|jalr       |1100111    |0x0    |      |
|lui        |0110111    |       |      |
|auipc      |0010111    |       |      |
|mtvec      |1110011    |       |      |
|mul        |0110011    |0x0    |0x01  |
|mulh       |0110011    |0x1    |0x01  |
|mulsu      |0110011    |0x2    |0x01  |
|mulu       |0110011    |0x3    |0x01  |
|div        |0110011    |0x4    |0x01  |
|divu       |0110011    |0x5    |0x01  |
|rem        |0110011    |0x6    |0x01  |
|remu       |0110011    |0x7    |0x01  |
|fcvt.s.w   |1010011    |N/A    |110100000000|
|fcvt.s.wu  |1010011    |N/A    |110100000001|
|fmv.w.x    |1010011    |000    |111100000000|
|fmv.x.w    |1010011    |000    |111000000000|
|fcvt.w.s   |1010011    |N/A    |110000000000|
|fcvt.wu.s  |1010011    |N/A    |110000000001|
|fclass.s   |1010011    |001    |111000000000|
|flw        |0000111    |010    |N/A         |
|fsw        |0100111    |010    |N/A         |

|fmax       |1010011    |001    |0010100     |
|fmin       |1010011    |000    |0010100     |

### TODO
|feq|||
|flt|||
|fle|||

|fsgnjx.s|||
|fsgnjn.s|||
|fsgnj.s|||

|fadd.s|||
|fsub.s|||
|fmul.s|||
|fdiv.s|||
|fmadd.s|||
|fmsub.s|||
|fnmsub.s|||
|fnmadd.s|||
|fsqrt.s|||

## Table2. System level instructions (implementation not completed)


| Instruction |  Opcode |  funct3 |  Description                                         |
|-------------|---------|---------|------------------------------------------------------|
| cssrrw      |  1110011 |  0x0    |  atomic read/write csr                               |
| cssrrs      |  1110011 |  0x1    |  atomic read & set bits in csr                       |
| cssrrc      |  1110011 |  0x2    |  atomic read & clear bits in csr                     |
| cssrwi      |  1110011 |  0x3    |  atomic read/write csr via immediate value           |
| cssrsi      |  1110011 |  0x4    |  atomic read & set bits in csr via immediate value   |
| cssrci      |  1110011 |  0x5    |  atomic read & clear bits in csr via immediate value |
| rdcycle     |  1110011 |  0x1    |  atomic read & set bits in cycle                     |
| rdcycleh    |  1110011 |  0x1    |  atomic read & set bits in cycleh                    |
| rdinstret   |  1110011 |  0x1    |  atomic read & set bits in instret                   |
| rdinstreth  |  1110011 |  0x1    |  atomic read & set bits in instreth                  |
| mret        |  1110011 |  0x6    |  Return from machine level trap                      |

## Table3. Exception table
| Interrupt   | Exception Code |Description |    
|:-------|:--------|:----------|
|1|7|Machine timer interrupt|
|0|0|instruction address misaligned|
|0|2|illegal instruction|
|0|4|load address misaligned|
|0|5|store address misaligned|

**Add RV32F support**
**Add context switching**

**Add dynamic pipelining (OoO execution)**

Speculative, Out of Order dynamic pipeline