# nproc
Implementation of a RV32I compliant RISC-V processor in Verilog

The implementation currently only supports user and machine mode execution

The implementation is byte addressable, load and store for half words and bytes is not completely supported and in actuality sign extends the byte/word to the entire 32bit width. Changing to support byte addressability might be considered in the future.

## Regarrays


TODO:

**Connect keyboard and VGA peripherals**

**Add exceptions**

implement ecall
implement ebreak

**Add interrupts**

**for RV32A support**
imlpement mul
implement mulh
implement mulsu
implement mulu
implement div
implement divu
implement rem
implement remu

**for RV32F support**

**Add dynamic pipelining (OoO execution)**

Speculative, Out of Order dynamic pipeline