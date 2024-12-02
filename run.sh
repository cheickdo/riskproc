cd verif
make SIM=icarus
cd ..
gtkwave -f verif/dump.vcd -F verif/div_default.gtkw
