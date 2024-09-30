cd verif
make SIM=icarus
cd ..
gtkwave verif/dump.vcd
