#Makefile

#defaults

SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(PWD)/../src/fmul.v 

TOPLEVEL = top

MODULE = tb

#proc_simple_test: $(MAKE) sim SIM_ARGS='-gARG=1' MODULE=tb TESTCASE=proc_simple_test

#fptest: $(MAKE) sim SIM_ARGS='-gARG=2' MODULE=tb TESTCASE=fptest

include $(shell cocotb-config --makefile)/Makefile.sim