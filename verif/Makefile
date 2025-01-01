#Makefile

#defaults

SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(PWD)/../src/proc.v $(PWD)/../src/regn.v 
VERILOG_SOURCES +=$(PWD)/../src/top.v $(PWD)/../src/memory.v $(PWD)/../src/regarray.v $(PWD)/../src/float/fregarray.v $(PWD)/../src/csr.v
VERILOG_SOURCES += $(PWD)/../src/interrupt_ctrl.v  $(PWD)/../src/counter.v $(PWD)/../src/float/fpu.v
VERILOG_SOURCES += $(PWD)/../src/float/fmul.v $(PWD)/../src/float/fpadd.v  $(PWD)/../src/float/fdiv.v  $(PWD)/../src/float/fsqrt.v  $(PWD)/../src/float/fcvt_s_w.v $(PWD)/../src/float/fcvt_s_wu.v  
VERILOG_SOURCES += $(PWD)/../src/float/fcvt_w_s.v $(PWD)/../src/float/fcvt_wu_s.v  $(PWD)/../src/float/fclass.v $(PWD)/../src/float/fmax.v $(PWD)/../src/float/fmin.v  
VERILOG_SOURCES += $(PWD)/../src/float/fsgnjx_s.v $(PWD)/../src/float/fsgnj_s.v  $(PWD)/../src/float/fsgnjn_s.v $(PWD)/../src/float/flt.v $(PWD)/../src/float/fle.v  $(PWD)/../src/float/feq.v
VERILOG_SOURCES += $(PWD)/../src/float/fmadd_s.v $(PWD)/../src/float/fnmadd_s.v 

VERILOG_SOURCES += $(PWD)/../src/dynamic/sync_fifo.v $(PWD)/../src/dynamic/dispatcher.v $(PWD)/../src/dynamic/pipeline.v $(PWD)/../src/dynamic/issue_queue.v 
VERILOG_SOURCES += $(PWD)/../src/alu.v $(PWD)/../src/agu.v
TOPLEVEL = top

MODULE = tb

#proc_simple_test: $(MAKE) sim SIM_ARGS='-gARG=1' MODULE=tb TESTCASE=proc_simple_test

#fptest: $(MAKE) sim SIM_ARGS='-gARG=2' MODULE=tb TESTCASE=fptest

include $(shell cocotb-config --makefile)/Makefile.sim