# nproc
Implementation of a RV32I compliant RISC-V processor in Verilog

The implementation currently only supports machine mode execution

The implementation is byte addressable

TODO:
**Add exceptions & interrupts**
**Connect keyboard and VGA peripherals**

| Interrupt   | Exception Code |Description |    
|:-------|:--------|:----------|
|0|0|instruction address misaligned|
|0|2|illegal instruction|
|0|4|load address misaligned|
|0|5|store address misaligned|

**Add RV32A support**
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