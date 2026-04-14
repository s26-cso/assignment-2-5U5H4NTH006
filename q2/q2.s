.globl main
.extern malloc
.extern free
.extern atoi
.extern printf

.section .rodata
fmt_space:
    .asciz "%d "
fmt_last:
    .asciz "%d\n"

.text
main:
    addi sp, sp, -64             # sp = new stack frame
    sd ra, 56(sp)
    sd s0, 48(sp)
    sd s1, 40(sp)
    sd s2, 32(sp)
    sd s3, 24(sp)
    sd s4, 16(sp)
    sd s5, 8(sp)
    sd s6, 0(sp)

    addi s0, a0, -1              # s0 = n = argc - 1
    mv s1, a1                    # s1 = argv
    bge x0, s0, q2_return_zero   # no input numbers

    # 3 arrays: vals, ans, stack
    slli a0, s0, 2               # a0 = n * 4 bytes
    call malloc
    mv s2, a0                    # s2 = values[]

    slli a0, s0, 2               # a0 = n * 4 bytes
    call malloc
    mv s3, a0                    # s3 = result[]

    slli a0, s0, 2               # a0 = n * 4 bytes
    call malloc
    mv s4, a0                    # s4 = stack[]

    li s6, 0                     # s6 = parse index

parse_loop:
    bge s6, s0, solve_setup      # done parsing
    addi t0, s6, 1               # t0 = argv idx = i + 1
    slli t0, t0, 3               # t0 = byte offset in argv
    add t0, s1, t0               # t0 = &argv[i + 1]
    ld a0, 0(t0)                 # a0 = argv[i + 1]
    call atoi
                                 # a0 = parsed int

    # parse once, keep it
    slli t1, s6, 2               # t1 = byte offset in values[]
    add t1, s2, t1               # t1 = &values[i]
    sw a0, 0(t1)                 # values[i] = parsed integer

    addi s6, s6, 1               # s6 = next parse index
    beq x0, x0, parse_loop

solve_setup:
    li s5, -1                    # s5 = top = -1
    addi s6, s0, -1              # s6 = i = n - 1

solve_loop:
    blt s6, x0, print_setup      # done with all i

    slli t0, s6, 2               # t0 = byte offset in values[]
    add t0, s2, t0               # t0 = &values[i]
    lw t1, 0(t0)                 # t1 = current value

pop_loop:
    blt s5, x0, store_minus_one  # empty stack -> -1

    slli t2, s5, 2               # t2 = byte offset in stack[]
    add t2, s4, t2               # t2 = &stack[top]
    lw t3, 0(t2)                 # t3 = top index

    slli t4, t3, 2               # t4 = byte offset for top val
    add t4, s2, t4               # t4 = &values[stack[top]]
    lw t5, 0(t4)                 # t5 = values[stack[top]]

    # pop while top <= cur
    blt t1, t5, store_stack_top  # keep top if top > cur
    addi s5, s5, -1              # s5 = new stack top
    beq x0, x0, pop_loop

store_stack_top:
    slli t0, s6, 2               # t0 = byte offset in result[]
    add t0, s3, t0               # t0 = &result[i]
    sw t3, 0(t0)                 # ans[i] = top index
    beq x0, x0, push_index

store_minus_one:
    slli t0, s6, 2               # t0 = byte offset in result[]
    add t0, s3, t0               # t0 = &result[i]
    li t6, -1                    # t6 = answer -1
    sw t6, 0(t0)                 # ans[i] = -1

push_index:
    # push i for elems on left
    addi s5, s5, 1               # s5 = new stack top
    slli t0, s5, 2               # t0 = byte offset in stack[]
    add t0, s4, t0               # t0 = &stack[top]
    sw s6, 0(t0)                 # stack[top] = cur i

    addi s6, s6, -1              # s6 = next i
    beq x0, x0, solve_loop

print_setup:
    li s6, 0                     # s6 = print index

print_loop:
    bge s6, s0, q2_clearstuff    # done printing

    slli t0, s6, 2               # t0 = byte offset in result[]
    add t0, s3, t0               # t0 = &result[i]
    lw a1, 0(t0)                 # a1 = result[i]

    addi t1, s0, -1              # t1 = last idx
    beq s6, t1, print_last_value

    la a0, fmt_space             # a0 = "%d "
    call printf
    addi s6, s6, 1               # s6 = next print index
    beq x0, x0, print_loop

print_last_value:
    la a0, fmt_last              # a0 = "%d\n"
    call printf
    addi s6, s6, 1               # s6 = next print index
    beq x0, x0, print_loop

q2_clearstuff:
    # free temp arrays
    mv a0, s4                    # a0 = stack[]
    call free
    mv a0, s3                    # a0 = result[]
    call free
    mv a0, s2                    # a0 = values[]
    call free
    li a0, 0                     # a0 = return code
    beq x0, x0, q2_done

q2_return_zero:
    li a0, 0                     # a0 = return code

q2_done:
    ld s6, 0(sp)
    ld s5, 8(sp)
    ld s4, 16(sp)
    ld s3, 24(sp)
    ld s2, 32(sp)
    ld s1, 40(sp)
    ld s0, 48(sp)
    ld ra, 56(sp)
    addi sp, sp, 64              # sp = old stack pointer
    ret
