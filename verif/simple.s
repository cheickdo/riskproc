lw x1 11(x0)
lw x2 12(x0)
lw x3 13(x0)
add x4 x1 x2
add x3 x4 x3
mv x5 x3
sub x3 x2 x1
sw x5 0(x0)
xor x1 x3 x2
or x2 x4 x3
and x2 x4 x1