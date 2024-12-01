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

    #check memory values within dut
    #for i in range(len(loadtest)):
    #    assert dut.mem0.my_mem[i] == loadtest[i]

    #dut.din = 0b000000001000000000011
    dut.resetn.value = 0
    dut.run.value = 1
    await RisingEdge(dut.clk)
    dut.resetn.value = 1
    await RisingEdge(dut.clk)

    
    for i in range(500):
        #val = random.randint(0, 1)
        #dut.d.value = val  # Assign the random value val to the input port d

        await RisingEdge(dut.clk)


        #assert dut.q.value == expected_val, f"output q was incorrect on the {i}th cycle"
        #expected_val = val # Save random value for next RisingEdge

    #assert dut.mem0.my_mem[0] == 9
    # Check the final input on the next clock
    #print(dut.mem0.my_mem[39].value)
    #print(dut.mem0.my_mem[40].value)
    #print(dut.mem0.my_mem[41].value)
    #print(dut.mem0.my_mem[42].value)
    #print(dut.mem0.my_mem[43].value)
    #print(dut.mem0.my_mem[44].value)
    #print(dut.mem0.my_mem[45].value)
    #print(dut.mem0.my_mem[46].value)
    #print(dut.mem0.my_mem[47].value)


    print("Test complete")

    #assert dut.q.value == expected_val, "output q was incorrect on the last cycle"


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
    f1 = (random() - 0.5)*(6.8*(10**12))
    f2 = (random() - 0.5)*(6.8*(10**12))
    #f1 = 1.5
    #f2 = -1.3
    fsum = f1+f2
    

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
    print(int(str(dut.out.value),2))
    print(int(binary(fsum),2))


    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    print("Test complete")



@cocotb.test()
async def fpmult(dut):
    """Test elementary functionality of processor"""


    clock = Clock(dut.clk, 100, units="ns")  
    cocotb.start_soon(clock.start(start_high=False))
    await RisingEdge(dut.clk)

    print("Starting test!")

    await RisingEdge(dut.clk)
    dut.resetn.value = 0
    await RisingEdge(dut.clk)
    dut.resetn.value = 1
    f1 = (random() - 0.5)*(6.8*(10**12))
    f2 = (random() - 0.5)*(6.8*(10**12))
    #f1 = -1.0
    #f2 = 2.0
    fsum = f1*f2
    

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


    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    print("Test complete")
