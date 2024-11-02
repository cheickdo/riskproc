START: addi x2, x0, 1
addi x3, x0, 2
addi x4,x0, 3
addi x5,x0, 4
blt x3, x2, START
sub x3, x3, x2
blt x3, x5, START
