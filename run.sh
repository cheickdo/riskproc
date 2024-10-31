cd verif
../Assembler/A-m
make SIM=icarus
cd ..
gtkwave -f verif/dump.vcd -F verif/default_signals.gtkw
