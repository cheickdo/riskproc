#Makefile

#defaults

SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(PWD)/../src/proc.v $(PWD)/../src/regn.v 
VERILOG_SOURCES +=$(PWD)/../src/top.v $(PWD)/../src/memory.v $(PWD)/../src/regarray.v $(PWD)/../src/csr.v
VERILOG_SOURCES += $(PWD)/../src/interrupt_ctrl.v  $(PWD)/../src/counter.v

TOPLEVEL = top

MODULE = tb

include $(shell cocotb-config --makefile)/Makefile.sim