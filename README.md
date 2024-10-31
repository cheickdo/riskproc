# nproc
Implementation of a RV32I compliant RISC-V processor in Verilog

The implementation is word addressable meaning that load and store for half words and bytes is not completely supported and in actuality sign extends the byte/word to the entire 32bit width. Changing to support byte addressability might be considered in the future.

TODO: Completing RV32I support

implement beq
implement bne
implement blt
implement bge
implement bltu
implement bgeu
implement jal
implement jalr
implement lui

Connect keyboard and VGA peripherals

Add pipelining

Add interrupts

implement auipc
implement ecall
implement ebreak


for RV32A support
imlpement mul
implement mulh
implement mulsu
implement mulu
implement div
implement divu
implement rem
implement remu

for RV32F support
tbc