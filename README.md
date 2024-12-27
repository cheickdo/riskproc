# riskproc
Implementation of a byte addressable RV32I, RV32M, RV32F compliant RISC-V processor in Verilog

The implementation currently only supports machine mode execution, and does not handle signaling NaN's in floating point interface or provide an interface to implement software handling of floating point exceptions. Memory mapping of csr's can be found in the doc section.

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
|auipc      |0010111    |       |       |
|mret      |1110011    |       |      |
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
|fsgnj.s    |1010011    |000    |0010000|
|fsgnjn.s   |1010011    |001    |0010000|
|fsgnjx.s   |1010011    |010    |0010000|
|feq        |1010011    |010    |1010000|
|flt        |1010011    |001    |1010000|
|fle        |1010011    |000    |1010000|
|fadd.s     |1010011    |N/A    |0000000|
|fsub.s     |1010011    |N/A    |0000100|
|fmul.s     |1010011    |000    |0001000|
|fdiv.s     |1010011    |000    |0001100|
|fsqrt.s    |1010011    |000    |010110000000|
|fmadd.s|1000011|000|||
|fmsub.s|1000111|000||
|fnmsub.s|1001011|000||
|fnmadd.s|1001111|000||

## Table2. System level instructions

| Instruction |  Opcode |  funct3 |  Description                                         |
|-------------|---------|---------|------------------------------------------------------|
| mret        |  1110011 |  0x6    |  Return from machine level trap                      |

## Table3. Exception table
| Interrupt   | Exception Code |Description |    
|:-------|:--------|:----------|
|1|7|Machine timer interrupt|
|0|0|instruction address misaligned|
|0|2|illegal instruction|
|0|4|load address misaligned|
|0|5|store address misaligned|

## Memory mapped addresses
Addresses in table are given as word-addresses. Real addresses are represented by a bitshift to the left by 2

| Address   | Internal mapping |Privilege        | Name | Description         |
|:-------|:--------|:----------|:-------------|:--------------------------------|
| 0xF00  |0x00| MRO | misa | ISA & supported extensions |
| 0xF01  |0x01| MRO | mvendorid | Vendor ID |
| 0xF02  |0x02| MRO | marchid | Architecture ID |
| 0xF03  |0x03| MRO | mimpid | Implementation ID |
| 0xF04  |0x04| MRO | mhartid | Hardware Thread ID |
| 0x300  |0x05| MRW | mstatus | Machine status register|
| 0x302  |0x06| MRW | medeleg | machine exception delegation register |
| 0x303  |0x07| MRW | mideleg | machine interrupt delegation register |
| 0x304  |0x08| MRW | mie | machine interrupt-enable register |
| 0x305  |0x09| MRW | mtvec | machine trap-handler base address |
| 0x340  |0x0A| MRW | mscratch | scratch register for machine trap handlers |
| 0x341  |0x0B| MRW | mepc | machine exception program counter |
| 0x342  |0x0C| MRW | mcause | machine trap cause |
| 0x343  |0x0D| MRW | mbadaddr | machine bad address |
| 0x344  |0x0E| MRW | mip | machine interrupt pending |
| 0xF00  |0x0F| MRO | mcycle | machine cycle counter|
| 0xF01  |0x10| MRO | mtime | machine wall-clock time|
| 0xF02  |0x11| MRO | minstret| machine instructions-retired counter |
| 0xF80  |0x12| MRO | mcycleh | upper 32b of mcycle |
| 0xF81  |0x13| MRO | mtimeh | upper 32b of mtime |
| 0xF82  |0x14| MRO | minsteth | upper 32b of minstret |
| 0x310  |0x15| MRW | mucounteren | user-mode counter enable |
| 0x311  |0x16| MRW | mscounteren | supervisor-mode counter enable |
| 0x312  |0x17| MRW | mhcounteren | hypervisor-mode counter enable |
| 0x700  |0x18| MRW | mucycle_delta | cycle counter delta |
| 0x701  |0x19| MRW | mutime_delta | time counter delta |
| 0x702  |0x1A| MRW | muinstret_delta | instret counter delta |
| 0x704  |0x1B| MRW | mscycle_delta | scycle counter delta |
| 0x705  |0x1C| MRW | mstime_delta | stime counter delta |
| 0x706  |0x1D| MRW | msinstret_delta | sinstret counter delta |
| 0x708  |0x1E| MRW | mhcycle_delta | hcycle counter delta |
| 0x709  |0x1F| MRW | mhtime_delta | htime counter delta |
| 0x70A  |0x20| MRW | mhinstret_delta | hinstret counter delta |
| 0x780  |0x21| MRW | mucycle_deltah | upper 32b of cycle counter delta |
| 0x781  |0x22| MRW | mutime_deltah | upper 32b of time counter delta |
| 0x782  |0x23| MRW | muinstret_deltah | upper 32b of instret counter delta|
| 0x784  |0x24| MRW | mscycle_deltah | upper 32b of scycle counter delta |
| 0x785  |0x25| MRW | mstime_deltah | upper 32b of stime counter delta |
| 0x786  |0x26| MRW | msinstret_deltah | upper 32b of sinstret counter delta |
| 0x788  |0x27| MRW | mhcycle_deltah | upper 32b of hcycle counter delta |
| 0x789  |0x28| MRW | mhtime_deltah | upper 32b of htime counter delta |
| 0x78A  |0x29| MRW | mhinstret_deltah | upper 32b of hinstret counter delta|
| 0x800  |0x2A| MRW | mtimecmp         | time comparison register|
| 0x801  |0x2B| MRW | mtimecmph        | upper 32b of time comparison register|
| 0x900  |0x2C| MRW | fcsr        | csr control and status register|

### TODO
- Add atomic instructions
- Refactor codebase
- Speculative, Out of Order dynamic pipeline
- Improve documentation
