onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label Resetn /testbench/Resetn
add wave -noupdate -label CLOCK_50 /testbench/CLOCK_50
add wave -noupdate -label Run /testbench/Run
add wave -noupdate -label Instruction -radix hexadecimal /testbench/Instruction
add wave -noupdate -divider proc
add wave -noupdate -label Resetn /testbench/U1/Resetn
add wave -noupdate -label Clock /testbench/U1/Clock
add wave -noupdate -label Run /testbench/U1/Run
add wave -noupdate -label DIN -radix hexadecimal /testbench/U1/DIN
add wave -noupdate -label Done /testbench/U1/Done
add wave -noupdate -label IR -radix hexadecimal /testbench/U1/IR
add wave -noupdate -label Tstep_Q /testbench/U1/Tstep_Q
add wave -noupdate -label r0 -radix hexadecimal /testbench/U1/r0
add wave -noupdate -label r1 -radix hexadecimal /testbench/U1/r1
add wave -noupdate -label r2 -radix hexadecimal /testbench/U1/r2
add wave -noupdate -label G -radix hexadecimal /testbench/U1/G
add wave -noupdate -label ADDR -radix hexadecimal /testbench/U1/ADDR
add wave -noupdate -label BusWires1 -radix hexadecimal /testbench/U1/BusWires1
add wave -noupdate -label BusWires2 -radix hexadecimal /testbench/U1/BusWires2
add wave -noupdate -label R_in -radix hexadecimal /testbench/U1/R_in
add wave -noupdate -label I_Imm -radix hexadecimal /testbench/U1/I_Imm
add wave -noupdate -label rd -radix hexadecimal /testbench/U1/rd
add wave -noupdate -label rs1 -radix hexadecimal /testbench/U1/rs1
add wave -noupdate -label rs2 -radix hexadecimal /testbench/U1/rs2
add wave -noupdate -label rin1 -radix hexadecimal /testbench/U1/R_in[1]
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {260000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 98
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {62500 ps} {312500 ps}
