#Makefile

#defaults

SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(PWD)/../src/proc.v $(PWD)/../src/regn.v 
VERILOG_SOURCES +=$(PWD)/../src/top.v $(PWD)/../src/memory.v $(PWD)/../src/regarray.v $(PWD)/../src/fregarray.v $(PWD)/../src/csr.v
VERILOG_SOURCES += $(PWD)/../src/interrupt_ctrl.v  $(PWD)/../src/counter.v $(PWD)/../src/fpu.v
VERILOG_SOURCES += $(PWD)/../src/fmul.v $(PWD)/../src/fpadd.v  $(PWD)/../src/fdiv.v  $(PWD)/../src/fsqrt.v  $(PWD)/../src/fcvt_s_w.v $(PWD)/../src/fcvt_s_wu.v  
VERILOG_SOURCES += $(PWD)/../src/fcvt_w_s.v $(PWD)/../src/fcvt_wu_s.v  $(PWD)/../src/fclass.v $(PWD)/../src/fmax.v $(PWD)/../src/fmin.v  
VERILOG_SOURCES += $(PWD)/../src/fsgnjx_s.v $(PWD)/../src/fsgnj_s.v  $(PWD)/../src/fsgnjn_s.v $(PWD)/../src/flt.v $(PWD)/../src/fle.v  $(PWD)/../src/feq.v
VERILOG_SOURCES += $(PWD)/../src/fmadd_s.v $(PWD)/../src/fnmadd_s.v 

TOPLEVEL = top

MODULE = tb

#proc_simple_test: $(MAKE) sim SIM_ARGS='-gARG=1' MODULE=tb TESTCASE=proc_simple_test

#fptest: $(MAKE) sim SIM_ARGS='-gARG=2' MODULE=tb TESTCASE=fptest

include $(shell cocotb-config --makefile)/Makefile.sim