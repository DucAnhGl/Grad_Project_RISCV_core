# Initialize registers
.global main
main:
    li t0, 0         # t0 = loop counter
    li t1, 64        # t1 = loop limit
    li t2, 0xAAAA    # t2 = alternating pattern (0b1010101010101010)
    li t3, 0         # t3 = accumulator

main_loop:
    # Branch based on alternating pattern
    srl t4, t2, t0  # Right shift t2 by t0
    andi t4, t4, 1   # Mask the least significant bit
    beqz t4, branch_a # If LSB == 0, go to branch_a
    j branch_b

branch_a:
    addi t3, t3, 1   # t3 = t3 + 1
    j next_iteration

branch_b:
    addi t3, t3, 2   # t3 = t3 + 2
    j next_iteration

next_iteration:
    # Increment loop counter
    addi t0, t0, 1
    blt t0, t1, main_loop # Continue if t0 < t1

    # Test a predictable loop pattern
    li t0, 0         # Reset loop counter
predictable_loop:
    andi t5, t0, 3   # t5 = t0 % 4
    beqz t5, branch_c # Branch every 4 iterations
    j branch_d

branch_c:
    addi t3, t3, 3   # t3 = t3 + 3
    j predictable_next

branch_d:
    addi t3, t3, -1   # t3 = t3 - 1
    j predictable_next

predictable_next:
    addi t0, t0, 1
    blt t0, t1, predictable_loop # Continue if t0 < t1

nop
nop
nop
nop
nop

end:
    j end