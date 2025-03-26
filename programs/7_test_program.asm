.global main
main:
    li t0, 0         # t0 = loop counter
    li t1, 10        # t1 = loop limit
    li t2, 0xA5A5    # t2 = alternating pattern (0b1010010110100101)
    li t3, 0         # t3 = accumulator

main_loop:
    srl t4, t2, t0   # Shift pattern by t0
    andi t4, t4, 1   # Mask the least significant bit

    beqz t4, branch_a  # If LSB == 0, go to branch_a
    bnez t4, branch_b  # If LSB != 0, go to branch_b
    blt t0, t1, branch_c # If t0 < t1, go to branch_c

branch_a:
    addi t3, t3, 2   # Increment accumulator by 2
    j check_end

branch_b:
    addi t3, t3, -1  # Decrement accumulator by 1
    j check_end

branch_c:
    addi t3, t3, 5   # Increment accumulator by 5

check_end:
    addi t0, t0, 1   # Increment counter
    blt t0, t1, main_loop # Loop until t0 >= t1

    # End of program
nop
nop
nop
nop
nop

end:
    j end
