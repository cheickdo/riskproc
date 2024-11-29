# riskproc
Implementation of a byte addressable RV32I, RV32M compliant RISC-V processor in Verilog

The implementation currently only supports machine mode execution

## Table1. System level instructions


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

## Table2. Exception table
| Interrupt   | Exception Code |Description |    
|:-------|:--------|:----------|
|0|0|instruction address misaligned|
|0|2|illegal instruction|
|0|4|load address misaligned|
|0|5|store address misaligned|

**Add RV32F support**

**Add dynamic pipelining (OoO execution)**

Speculative, Out of Order dynamic pipeline