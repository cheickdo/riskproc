from random import random
import time

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.types import LogicArray
import struct
import ctypes

def binary(num):
    return ''.join('{:0>8b}'.format(c) for c in struct.pack('!f', num))

@cocotb.test()
async def fptest(dut):
    """Test elementary functionality of processor"""


    clock = Clock(dut.clk, 100, units="ns")  
    cocotb.start_soon(clock.start(start_high=False))
    await RisingEdge(dut.clk)

    print("Starting test!")

    await RisingEdge(dut.clk)
    dut.resetn.value = 0
    await RisingEdge(dut.clk)
    dut.resetn.value = 1
    #f1 = (random() - 0.5)*(6.8*(10**12))
    #f2 = (random() - 0.5)*(6.8*(10**12))
    f1 = 1.0
    f2 = 1.0
    fsum = f1/f2
    

    print(f1)
    print(f2)
    print(fsum, end='\n\n')

    print(binary(f1))
    print(binary(f2))
    print(fsum, end='\n\n')

    print(binary(fsum))

    dut.rs1.value = int(binary(f1),2)
    dut.rs2.value = int(binary(f2),2)

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    print(dut.out.value)
    #print(int(binary(fsum),2))

    for i in range(50):
        await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    print("Test complete")