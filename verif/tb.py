
import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.types import LogicArray

@cocotb.test()
async def dff_simple_test(dut):
    """Test that d propagates to q"""

    # Assert initial output is unknown
    #assert LogicArray(dut.q.value) == LogicArray("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
    # Set initial input value to prevent it from floating
    #dut.d.value = 0

    clock = Clock(dut.clk, 100, units="ns")  # Create a 100ns period clock on port clk
    # Start the clock. Start it low to avoid issues on the first RisingEdge
    cocotb.start_soon(clock.start(start_high=False))

    # Synchronize with the clock. This will regisiter the initial `d` value
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    #dut.din = 0b000000001000000000011
    dut.resetn = 0
    dut.run = 1
    await RisingEdge(dut.clk)
    dut.resetn = 1
    await RisingEdge(dut.clk)
    
    for i in range(30):
        #val = random.randint(0, 1)
        #dut.d.value = val  # Assign the random value val to the input port d

        await RisingEdge(dut.clk)


        #assert dut.q.value == expected_val, f"output q was incorrect on the {i}th cycle"
        #expected_val = val # Save random value for next RisingEdge

    # Check the final input on the next clock

    #assert dut.q.value == expected_val, "output q was incorrect on the last cycle"