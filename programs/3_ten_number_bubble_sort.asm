# Array values: [10, 9, 8, 7, 6, 5, 4, 3, 2, 1] are stored in registers.
# Registers t0 to t6, and a0 to a3 are used for array elements.
.global main
main:
    li t0, 10       # array[0]
    li t1, 9        # array[1]
    li t2, 8        # array[2]
    li t3, 7        # array[3]
    li t4, 6        # array[4]
    li t5, 5        # array[5]
    li t6, 4        # array[6]
    li a0, 3        # array[7]
    li a1, 2        # array[8]
    li a2, 1        # array[9]

    # Outer loop counter i (fixed at 9 iterations for 10 elements)
    li s0, 9        # Set outer loop counter to 9 (number of passes)

outer_loop:
    li s1, 0        # Inner loop counter j, reset each outer loop iteration

inner_loop:
    # Set up comparisons based on j using available registers

    # Default comparison between t0 and t1
    mv a3, t0        # Use a3 as array[j] in comparisons
    mv a4, t1        # Use a4 as array[j+1] in comparisons

    li a5, 1
    beq s1, a5, cmp_12  # If j == 1, compare t1 and t2
    li a5, 2
    beq s1, a5, cmp_23  # If j == 2, compare t2 and t3
    li a5, 3
    beq s1, a5, cmp_34  # If j == 3, compare t3 and t4
    li a5, 4
    beq s1, a5, cmp_45  # If j == 4, compare t4 and t5
    li a5, 5
    beq s1, a5, cmp_56  # If j == 5, compare t5 and t6
    li a5, 6
    beq s1, a5, cmp_67  # If j == 6, compare t6 and a0
    li a5, 7
    beq s1, a5, cmp_78  # If j == 7, compare a0 and a1
    li a5, 8
    beq s1, a5, cmp_89  # If j == 8, compare a1 and a2
    j compare           # Jump to comparison logic

cmp_12:
    mv a3, t1
    mv a4, t2
    j compare

cmp_23:
    mv a3, t2
    mv a4, t3
    j compare

cmp_34:
    mv a3, t3
    mv a4, t4
    j compare

cmp_45:
    mv a3, t4
    mv a4, t5
    j compare

cmp_56:
    mv a3, t5
    mv a4, t6
    j compare

cmp_67:
    mv a3, t6
    mv a4, a0
    j compare

cmp_78:
    mv a3, a0
    mv a4, a1
    j compare

cmp_89:
    mv a3, a1
    mv a4, a2

compare:
    # Compare a3 (array[j]) and a4 (array[j+1])
    blt a3, a4, no_swap  # If array[j] < array[j+1], skip the swap

    # Swap array[j] and array[j+1]
    beq s1, x0, swap_01  # If j == 0, swap t0 and t1
    li a5, 1
    beq s1, a5, swap_12  # If j == 1, swap t1 and t2
    li a5, 2
    beq s1, a5, swap_23  # If j == 2, swap t2 and t3
    li a5, 3
    beq s1, a5, swap_34  # If j == 3, swap t3 and t4
    li a5, 4
    beq s1, a5, swap_45  # If j == 4, swap t4 and t5
    li a5, 5
    beq s1, a5, swap_56  # If j == 5, swap t5 and t6
    li a5, 6
    beq s1, a5, swap_67  # If j == 6, swap t6 and a0
    li a5, 7
    beq s1, a5, swap_78  # If j == 7, swap a0 and a1
    li a5, 8
    beq s1, a5, swap_89  # If j == 8, swap a1 and a2

swap_01:
    mv t0, a4
    mv t1, a3
    j next_inner

swap_12:
    mv t1, a4
    mv t2, a3
    j next_inner

swap_23:
    mv t2, a4
    mv t3, a3
    j next_inner

swap_34:
    mv t3, a4
    mv t4, a3
    j next_inner

swap_45:
    mv t4, a4
    mv t5, a3
    j next_inner

swap_56:
    mv t5, a4
    mv t6, a3
    j next_inner

swap_67:
    mv t6, a4
    mv a0, a3
    j next_inner

swap_78:
    mv a0, a4
    mv a1, a3
    j next_inner

swap_89:
    mv a1, a4
    mv a2, a3

no_swap:
next_inner:
    addi s1, s1, 1         # j++
    li a5, 9               # Inner loop limit (9 iterations for 10 elements)
    blt s1, a5, inner_loop # If j < 9, continue inner loop

    # Decrement outer loop counter
    addi s0, s0, -1
    bnez s0, outer_loop    # Continue outer loop if s0 != 0

nop
nop
nop
nop
nop


end:
    j end                  # Jump to itself, creating an infinite loop
