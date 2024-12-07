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
async def proc_simple_test(dut):
    """Test elementary functionality of processor"""

    # Assert initial output is unknown
    #assert LogicArray(dut.q.value) == LogicArray("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
    # Set initial input value to prevent it from floating
    #dut.d.value = 0

    clock = Clock(dut.clk, 100, units="ns")  # Create a 100ns period clock on port clk
    # Start the clock. Start it low to avoid issues on the first RisingEdge
    cocotb.start_soon(clock.start(start_high=False))

    # Synchronize with the clock. This will regisiter the initial `d` value
    await RisingEdge(dut.clk)

    #set memory values within dut
    

    #for i in range(len(loadtest)):
    #    dut.mem0.my_mem[i] = loadtest[i]
    
    #f = open("../RISCVAssembly_To_MIF/Assembler/BINARY.mc", "r")
    f = open("BINARY.mc", "r")

    lines = f.readlines()

    j = 0

    print("Loading memory...")
    for line in lines:
        #print(line)
        #print(bin(int(line,2)))
        #print()
        dut.mem0.my_mem[j] = int(line,2)
        print(line.rstrip('\n'))
        #print(line, end = '')
        j += 1


    f.close()

    print("Starting test!")


    await RisingEdge(dut.clk)
    print(dut.mem0.my_mem[6].value)
    #check memory values within dut
    #for i in range(len(loadtest)):
    #    assert dut.mem0.my_mem[i] == loadtest[i]

    #dut.din = 0b000000001000000000011
    dut.resetn.value = 0
    dut.run.value = 1
    await RisingEdge(dut.clk)
    dut.resetn.value = 1
    await RisingEdge(dut.clk)
    for i in range(200):
        await RisingEdge(dut.clk)

    print(dut.mem0.my_mem[6].value)


    print("Test complete")

    #assert dut.q.value == expected_val, "output q was incorrect on the last cycle"
