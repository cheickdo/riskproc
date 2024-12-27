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
async def dispatcher_test(dut):
    """Test elementary functionality of processor"""
    start = 0
    
    arr = [
        "00001000110000000000000011101111",
        "00000000001100000000000100010011",
        "00000000100000010001000100010011",
        "00000000010000010000000100010011",
        "00000000001000010001000100010011",
        "00000000000000010010000000100011",
        "00000001000001100010000000100011",
        "00000001000101100010001000100011",
        "00000001001001100010010000100011",
        "00000001001101100010011000100011",
        "00000000000001100010011000100011",
        "00000000000110000000100000010011",
        "00000000000110001000100010010011",
        "00000000111100000000001110010011",
        "00000000000000111010010000000011",
        "00100000000000111010010010000011",
        "00010000000000000000101000010111",
        "00000000000000000000000001000011",
    ]
    for i in range(len(arr)):
        arr[i] = int(arr[i],2)
    


    clock = Clock(dut.clk, 1, units="ns")  
    cocotb.start_soon(clock.start(start_high=False))
    await RisingEdge(dut.clk)

    print("Starting test!")

    await RisingEdge(dut.clk)
    dut.resetn.value = 0
    await RisingEdge(dut.clk)
    dut.resetn.value = 1

    for i in range(3):
        await RisingEdge(dut.clk)

    dut.data_in_ifq.value = arr[start]
    start = start + 1
    dut.enq_ifq.value = 1
    dut.deq_ifq.value = 0
    await RisingEdge(dut.clk)
    dut.data_in_ifq.value = arr[start]
    start = start + 1
    dut.enq_ifq.value = 1
    dut.deq_ifq.value = 0
    await RisingEdge(dut.clk)
    dut.data_in_ifq.value = arr[start]
    start = start + 1
    dut.enq_ifq.value = 1
    dut.deq_ifq.value = 0
    await RisingEdge(dut.clk)
    dut.data_in_ifq.value = arr[start]
    start = start + 1
    dut.enq_ifq.value = 1
    dut.deq_ifq.value = 0
    await RisingEdge(dut.clk)
    dut.data_in_ifq.value = arr[start]
    start = start + 1
    dut.enq_ifq.value = 1
    dut.deq_ifq.value = 0
    await RisingEdge(dut.clk)
    dut.deq_ifq.value = 1
    await RisingEdge(dut.clk)
    dut.data_in_ifq.value = arr[start]
    start = start + 1
    await RisingEdge(dut.clk)
    dut.data_in_ifq.value = arr[start]
    start = start + 1
    await RisingEdge(dut.clk)
    dut.data_in_ifq.value = arr[start]
    start = start + 1
    await RisingEdge(dut.clk)
    dut.data_in_ifq.value = arr[start]
    start = start + 1
    await RisingEdge(dut.clk)
    dut.data_in_ifq.value = arr[start]
    start = start + 1
    await RisingEdge(dut.clk)
    dut.data_in_ifq.value = arr[start]
    start = start + 1
    await RisingEdge(dut.clk)
    dut.data_in_ifq.value = arr[start]
    start = start + 1
    await RisingEdge(dut.clk)
    dut.data_in_ifq.value = arr[start]
    start = start + 1
    dut.enq_ifq.value = 1
    dut.deq_ifq.value = 1
    await RisingEdge(dut.clk)
    dut.data_in_ifq.value = arr[start]
    start = start + 1
    await RisingEdge(dut.clk)
    dut.data_in_ifq.value = arr[start]
    start = start + 1
    await RisingEdge(dut.clk)
    dut.data_in_ifq.value = arr[start]
    start = start + 1
    await RisingEdge(dut.clk)
    dut.data_in_ifq.value = arr[start]
    start = start + 1
    await RisingEdge(dut.clk)
    dut.data_in_ifq.value = arr[start]
    start = start + 1
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    print("Test complete")
