from random import random
import time

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.types import LogicArray
import struct
import ctypes
import math


@cocotb.test()
async def sync_fifo_test(dut):
    """Test elementary functionality of processor"""
    start = 0

    clock = Clock(dut.clk, 1, units="ns")  
    cocotb.start_soon(clock.start(start_high=False))
    await RisingEdge(dut.clk)

    print("Starting test!")

    await RisingEdge(dut.clk)
    dut.data_in.value = start
    dut.resetn.value = 0
    await RisingEdge(dut.clk)
    dut.resetn.value = 1

    for i in range(3):
        await RisingEdge(dut.clk)

    dut.enq.value = 1
    dut.deq.value = 0
    for i in range(10):
        await RisingEdge(dut.clk)
        dut.data_in.value = start
        start = start + 1

    for i in range(3):
        dut.enq.value = 0
        dut.deq.value = 1
        await RisingEdge(dut.clk)
    
    for i in range(10):
        await RisingEdge(dut.clk)
        dut.data_in.value = start
        dut.deq.value = 1
        dut.enq.value = 1
        start = start + 1

    dut.resetn = 0
    await RisingEdge(dut.clk)
    dut.resetn = 1

    for i in range(10):
        await RisingEdge(dut.clk)
        dut.deq.value = 1
        dut.enq.value = 1

    print("Test complete")
