# Initialize some registers
    li t0, 0       # t0 = loop counter
    li t1, 50      # t1 = loop limit
    li t2, 0x01    # t2 = bit toggle value
    li t3, 0       # t3 = accumulator
    
main_loop:
    # Branch with a predictable pattern
    andi t4, t0, 1 # t4 = t0 & 1 (check even/odd)
    beqz t4, even_branch # Branch if t0 is even
    j odd_branch

even_branch:
    addi t3, t3, 2  # t3 = t3 + 2
    j next_iteration

odd_branch:
    addi t3, t3, 1  # t3 = t3 + 1
    j next_iteration

next_iteration:
    # Branch with an unpredictable pattern
    xor t2, t2, t0  # Flip bits in t2 based on t0
    andi t5, t2, 0x1 # t5 = t2 & 1
    beqz t5, unpredictable_branch # Branch if result is zero
    j predictable_branch

unpredictable_branch:
    addi t3, t3, 4  # Arbitrary operation
    j update_loop

predictable_branch:
    addi t3, t3, -2  # Arbitrary operation
    j update_loop

update_loop:
    # Increment loop counter
    addi t0, t0, 1
    blt t0, t1, main_loop # Continue if t0 < t1
    
    
    # Initialize registers
    li t0, 0         # t0 = loop counter
    li t1, 64        # t1 = loop limit
    li t2, 1         # t2 = default alignment toggle
    li t3, 0         # t3 = accumulator

main_loop2:
    # Branch predominantly "not taken"
    andi t4, t0, 3   # t4 = t0 % 4 (modulo operation)
    beqz t4, mostly_not_taken # If t0 % 4 == 0, take the branch
    j mostly_taken

mostly_not_taken:
    addi t3, t3, 1   # t3 = t3 + 1
    j next_iteration2

mostly_taken:
    addi t3, t3, 2   # t3 = t3 + 2
    j next_iteration2

next_iteration2:
    # Increment loop counter
    addi t0, t0, 1
    blt t0, t1, main_loop2 # Continue if t0 < t1

    # Test consistent default behavior
    li t0, 0         # Reset loop counter
default_behavior_loop:
    andi t5, t0, 7   # t5 = t0 % 8
    beqz t5, branch_default # Branch default direction (not taken)
    j branch_other

branch_default:
    addi t3, t3, -1   # t3 = t3 - 1
    j default_next

branch_other:
    addi t3, t3, 3   # t3 = t3 + 3
    j default_next

default_next:
    addi t0, t0, 1
    blt t0, t1, default_behavior_loop # Continue if t0 < t1
    
    # Initialize registers
    li t0, 0         # t0 = loop counter
    li t1, 64        # t1 = loop limit
    li t2, 0xAAAA    # t2 = alternating pattern (0b1010101010101010)
    li t3, 0         # t3 = accumulator

main_loop3:
    # Branch based on alternating pattern
    srl t4, t2, t0  # Right shift t2 by t0
    andi t4, t4, 1   # Mask the least significant bit
    beqz t4, branch_a # If LSB == 0, go to branch_a
    j branch_b

branch_a:
    addi t3, t3, 1   # t3 = t3 + 1
    j next_iteration3

branch_b:
    addi t3, t3, 2   # t3 = t3 + 2
    j next_iteration3

next_iteration3:
    # Increment loop counter
    addi t0, t0, 1
    blt t0, t1, main_loop3 # Continue if t0 < t1

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
    