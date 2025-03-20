
li  x1 , 0xDEADBEEF # load test value into register
li  x2 , 0x20000    # address of LEDR
li  x3 , 0x20004    # address of HEX0
li  x4 , 0x13000    # address of a byte in Data memory

sb  x1 , 0(x2)      # LEDR = 0x0000_00EF
lb  x10, 0(x2)      # x10 = 0xFFFF_FFEF

sb  x1 , 0(x3)      # HEX0 = 0x6F
sw  x1 , 0(x2)      # LEDR = 0xDEADBEEF
sh  x1 , 0(x3)      # HEX0 = 0x6F
                    # HEX1 = 0x3E
sh  x1 , 2(x3)      # HEX2 = 0x6F
                    # HEX3 = 0x3E
lbu x11, 0(x3)      # x11 = 0xEF

sw  x0 , 0(x4)
sw  x0 , 4(x4)
sw  x0 , 8(x4)

sw  x1 , 0(x4)      # mem[0x2000] = 0xDEADBEEF
lw  x12, 0(x4)      # x12 = 0xDEADBEEF
lh  x13, 0(x4)      # x13 = 0xFFFFBEEF
lhu x13, 0(x4)      # x13 = 0x0000BEEF
lb  x14, 0(x4)      # x14 = 0xFFFFFFEF
lbu x14, 0(x4)      # x14 = 0x000000EF

sb  x1 , 4(x4)      # mem[0x2004] = 0xDEADBEEF
lw  x12, 4(x4)      # x12 = 0x000000EF
lh  x13, 4(x4)      # x13 = 0x000000EF
lhu x13, 4(x4)      # x13 = 0x000000EF
lb  x14, 4(x4)      # x14 = 0xFFFFFFEF
lbu x14, 4(x4)      # x14 = 0x000000EF

sh  x1 , 8(x4)      # mem[0x2008] = 0x0000BEEF
lw  x12, 8(x4)      # x12 = 0x0000BEEF
lh  x13, 8(x4)      # x13 = 0xFFFFBEEF
lhu x13, 8(x4)      # x13 = 0x0000BEEF
lb  x14, 8(x4)      # x14 = 0xFFFFFFEF
lbu x14, 8(x4)      # x14 = 0x000000EF




#5 nops to end the simulation
nop
nop
nop
nop
nop
