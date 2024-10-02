
import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.types import LogicArray

#Load HW to reg 0 (broken?), load W to reg 1 from memory 3, load W to reg 2 from memory 4, add reg 1 and reg 2 and store in reg 3
loadtest = [0b000000001000000000011, 0b1111111001000010000011, 0b10011111001000100000011, 2, 3, ]

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
    
    f = open("result.txt", "r")
    lines = f.readlines()

    j = 0
    for line in lines:
        #print(line)
        #print(bin(int(line,2)))
        #print()

        dut.mem0.my_mem[j] = int(line,2)
        j += 1


    f.close()

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

    
    for i in range(70):
        #val = random.randint(0, 1)
        #dut.d.value = val  # Assign the random value val to the input port d

        await RisingEdge(dut.clk)


        #assert dut.q.value == expected_val, f"output q was incorrect on the {i}th cycle"
        #expected_val = val # Save random value for next RisingEdge

    assert dut.mem0.my_mem[0] == 9
    # Check the final input on the next clock

    #assert dut.q.value == expected_val, "output q was incorrect on the last cycle"