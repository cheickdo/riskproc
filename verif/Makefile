#Makefile

#defaults

SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(PWD)/../src/proc.v $(PWD)/../src/regn.v $(PWD)/../src/top.v $(PWD)/../src/memory.v

TOPLEVEL = top

MODULE = tb

include $(shell cocotb-config --makefile)/Makefile.sim