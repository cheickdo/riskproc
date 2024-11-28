START: jal x1, PROGRAM #branch to program
TRAP: mtvec
PROGRAM:addi x2, x0, 3
slli x2, x2, 8 #test comment
addi x2, x2, 5
slli x2, x2, 2
addi x1, x0 ,1
sw x1, 0(x2) #write to mtvec
addi x4, x0, 8
slli x4, x4, 8
slli x4, x4, 2
sw x4, 0(x4)
srli x4, x4, 2
addi x4, x4, 1
slli x4, x4, 2
sw x4, 0(x4)
addi x2, x0, 1
addi x2, x0, 1
addi x2, x0, 1