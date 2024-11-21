
Currently allocated CSR addresses

Field specification format:
WIRI: 2'b00
WPRI: 2'b01
WLRL: 2'b10
WARL: 2'b11



| Address   | Internal mapping |Privilege        | Name | Description         |
|:-------|:--------|:----------|:-------------|:--------------------------------|
| 0xF00  |0x00| MRO | misa | ISA & supported extensions |
| 0xF01  |0x01| MRO | mvendorid | Vendor ID |
| 0xF02  |0x02| MRO | marchid | Architecture ID |
| 0xF03  |0x03| MRO | mimpid | Implementation ID |
| 0xF04  |0x04| MRO | mhartid | Hardware Thread ID |
| 0x300  |0x05| MRW | mstatus | Machine status register|
| 0x302  |0x06| MRW | medeleg | machine exception delegation register |
| 0x303  |0x07| MRW | mideleg | machine interrupt delegation register |
| 0x304  |0x08| MRW | mie | machine interrupt-enable register |
| 0x305  |0x09| MRW | mtvec | machine trap-handler base address |
| 0x340  |0x0A| MRW | mscrtatch | scratch register for machine trap handlers |
| 0x341  |0x0B| MRW | mepc | machine exception program counter |
| 0x342  |0x0C| MRW | mcause | machine trap cause |
| 0x343  |0x0D| MRW | mbadaddr | machine bad address |
| 0x344  |0x0E| MRW | mip | machine interrupt pending |
| 0xF00  |0x0F| MRO | mcycle | machine cycle counter|
| 0xF01  |0x10| MRO | mtime | machine wall-clock time|
| 0xF02  |0x11| MRO | minstret| machine instructions-retired counter |
| 0xF80  |0x12| MRO | mcycleh | upper 32b of mcycle |
| 0xF81  |0x13| MRO | mtimeh | upper 32b of mtime |
| 0xF82  |0x14| MRO | minsteth | upper 32b of minstret |
| 0x310  |0x15| MRW | mucounteren | user-mode counter enable |
| 0x311  |0x16| MRW | mscounteren | supervisor-mode counter enable |
| 0x312  |0x17| MRW | mhcounteren | hypervisor-mode counter enable |
| 0x700  |0x18| MRW | mucycle_delta | cycle counter delta |
| 0x701  |0x19| MRW | mutime_delta | time counter delta |
| 0x702  |0x1A| MRW | muinstret_delta | instret counter delta |
| 0x704  |0x1B| MRW | mscycle_delta | scycle counter delta |
| 0x705  |0x1C| MRW | mstime_delta | stime counter delta |
| 0x706  |0x1D| MRW | msinstret_delta | sinstret counter delta |
| 0x708  |0x1E| MRW | mhcycle_delta | hcycle counter delta |
| 0x709  |0x1F| MRW | mhtime_delta | htime counter delta |
| 0x70A  |0x20| MRW | mhinstret_delta | hinstret counter delta |
| 0x780  |0x21| MRW | mucycle_deltah | upper 32b of cycle counter delta |
| 0x781  |0x22| MRW | mutime_deltah | upper 32b of time counter delta |
| 0x782  |0x23| MRW | muinstret_deltah | upper 32b of instret counter delta|
| 0x784  |0x24| MRW | mscycle_deltah | upper 32b of scycle counter delta |
| 0x785  |0x25| MRW | mstime_deltah | upper 32b of stime counter delta |
| 0x786  |0x26| MRW | msinstret_deltah | upper 32b of sinstret counter delta |
| 0x788  |0x27| MRW | mhcycle_deltah | upper 32b of hcycle counter delta |
| 0x789  |0x28| MRW | mhtime_deltah | upper 32b of htime counter delta |
| 0x78A  |0x29| MRW | mhinstret_deltah | upper 32b of hinstret counter delta|
