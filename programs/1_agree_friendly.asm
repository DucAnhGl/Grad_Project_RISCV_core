
.global main
main:
    nop
    # Initialize registers
    li      t0, 0              # Initialize loop counter (t0)
    li      t1, 100             # Loop limit (10 iterations)

loop:
    addi    t0, t0, 1          # Increment loop counter
    bge     t0, t1, end        # Branch if t0 >= t1

    # Simulate the branch behavior: First-time branch direction
    blt     t0, t1, loop       # If t0 == t1, branch back to loop (this would be the first-time bias)

    #j       loop                # Jump back to loop if not branch (continuing normally)
nop
nop
nop
nop
nop
nop

end:
    j end
