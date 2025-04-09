.global main
main:


    # li   x2, 0x000000AA
    # li   x3, 0x00000055
    # li   x5, 0x0F
    # li   x6, 0xF0
    # li   x4, 0x20000
    li   x3, 0x10004

    li   x4, 0x20004
    #li   x5, 0x30000

    #li   x2, 0x30 

#loop:
    #sw   x2, 0(x4)

    # li   x10, 50000000
    # delay_loop: 
    #     addi x10, x10, -1           # Decrement the counter

    #     bne  x10, x0, delay_loop    # If t0 is not zero, branch back to delay_loop

    #jal  x1, delay_1s

    #sw   x3, 0(x4)

    # li   x10, 50000000
    # delay_loop1: 
    #     addi x10, x10, -1           # Decrement the counter
    #     bne  x10, x0, delay_loop1    # If t0 is not zero, branch back to delay_loop

    #jal  x1, delay_2s

    #j loop

    #lw   x6, 0(x5)

    # li   x10, 5

# delay_loop1: 
#     addi x10, x10, -1           # Decrement the counter
#     bne  x10, x0, delay_loop1    # If t0 is not zero, branch back to delay_loop
    #sw   x2, 0(x3) 

    lw   x5, 0(x3)

    sb   x5, 0(x4)

loop:  
    j loop

# delay_1s:
    
#     li   x10, 25000000                 # Load 50 million into t0 (1 second delay for 50 MHz clock)
# delay_loop: 
#     addi x10, x10, -1           # Decrement the counter
#     bne  x10, x0, delay_loop    # If t0 is not zero, branch back to delay_loop
      
#     jalr x0,x1,0                # Return from the function

# delay_2s:
#     li   x10, 50000000                 # Load 50 million into t0 (1 second delay for 50 MHz clock)
# delay_loop_1: 
#     addi x10, x10, -1           # Decrement the counter
#     bne  x10, x0, delay_loop_1   # If t0 is not zero, branch back to delay_loop
#     jalr x0,x1,0                # Return from the function

    

# exit:
#     nop
#     nop
#     nop
#     nop
#     nop

# end:
#     j end
    