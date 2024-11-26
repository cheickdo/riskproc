# nproc
Implementation of a byte addressable RV32I compliant RISC-V processor in Verilog

The implementation currently only supports machine mode execution

Table1. System level instructions implemented


| Instruction |  Opcode |  funct3 |  Description                                         |
|-------------|---------|---------|------------------------------------------------------|
| cssrrw      |  111011 |  0x0    |  atomic read/write csr                               |
| cssrrs      |  111011 |  0x1    |  atomic read & set bits in csr                       |
| cssrrc      |  111011 |  0x2    |  atomic read & clear bits in csr                     |
| cssrwi      |  111011 |  0x3    |  atomic read/write csr via immediate value           |
| cssrsi      |  111011 |  0x4    |  atomic read & set bits in csr via immediate value   |
| cssrci      |  111011 |  0x5    |  atomic read & clear bits in csr via immediate value |
| rdcycle     |  111011 |  0x1    |  atomic read & set bits in cycle                     |
| rdcycleh    |  111011 |  0x1    |  atomic read & set bits in cycleh                    |
| rdinstret   |  111011 |  0x1    |  atomic read & set bits in instret                   |
| rdinstreth  |  111011 |  0x1    |  atomic read & set bits in instreth                  |

TODO:
**Add exceptions & interrupts**
**Connect keyboard and VGA peripherals**

| Interrupt   | Exception Code |Description |    
|:-------|:--------|:----------|
|0|0|instruction address misaligned|
|0|2|illegal instruction|
|0|4|load address misaligned|
|0|5|store address misaligned|

**Add RV32M support**
imlpement mul
implement mulh
implement mulsu
implement mulu
implement div
implement divu
implement rem
implement remu

**Add RV32F support**

**Add dynamic pipelining (OoO execution)**

Speculative, Out of Order dynamic pipeline