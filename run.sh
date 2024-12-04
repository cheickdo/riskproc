cd verif
make SIM=icarus
cd ..
gtkwave -f verif/dump.vcd -F verif/default.gtkw
