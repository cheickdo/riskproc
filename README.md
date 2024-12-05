# riskproc
Implementation of a byte addressable RV32I, RV32M compliant RISC-V processor in Verilog

The implementation currently only supports machine mode execution

## Table1. Instruction set


|Instruction|Opcode     |funct3 |funct7|
|-----------|-----------|-------|------|
|add        |110011     |0x0    |0x00  |
|sub        |110011     |0x0    |0x20  |
|xor        |110011     |0x4    |0x00  |
|or         |110011     |0x6    |0x00  |
|and        |110011     |0x7    |0x00  |
|sll        |110011     |0x1    |0x00  |
|srl        |110011     |0x5    |0x00  |
|sra        |110011     |0x5    |0x20  |
|slt        |110011     |0x2    |0x00  |
|sltu       |110011     |0x3    |0x00  |
|addi       |10011      |0x0    |      |
|xori       |10011      |0x4    |      |
|ori        |10011      |0x6    |      |
|andi       |10011      |0x7    |      |
|slli       |10011      |0x1    |0x00  |
|srli       |10011      |0x5    |0x00  |
|srai       |10011      |0x5    |0x20  |
|sltiu      |10011      |0x2    |      |
|sltiu      |10011      |0x3    |      |
|lb         |11         |0x0    |      |
|lh         |11         |0x1    |      |
|lw         |11         |0x2    |      |
|lbu        |11         |0x4    |      |
|lhu        |11         |0x5    |      |
|sb         |100011     |0x0    |      |
|sh         |100011     |0x1    |      |
|sw         |100011     |0x2    |      |
|beq        |1100011    |0x0    |      |
|bne        |1100011    |0x1    |      |
|blt        |1100011    |0x4    |      |
|bge        |1100011    |0x5    |      |
|bltu       |1100011    |0x6    |      |
|bgeu       |1100011    |0x7    |      |
|jal        |1101111    |0x0    |      |
|jalr       |1100111    |0x0    |      |
|lui        |110111     |       |      |
|auipc      |10111      |       |      |
|mul        |110011     |0x0    |0x01  |
|mulh       |110011     |0x1    |0x01  |
|mulsu      |110011     |0x2    |0x01  |
|mulu       |110011     |0x3    |0x01  |
|div        |110011     |0x4    |0x01  |
|divu       |110011     |0x5    |0x01  |
|rem        |110011     |0x6    |0x01  |
|remu       |110011     |0x7    |0x01  |
|fcvt.s.w   |1010011    |N/A    |110100000000|


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

**Add dynamic pipelining (OoO execution)**

Speculative, Out of Order dynamic pipeline