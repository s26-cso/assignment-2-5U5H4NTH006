    .section .rodata
fname:
    .asciz "input.txt"
readmode:
    .asciz "r"
affirmative:
    .asciz "Yes"
negative:
    .asciz "No"

    .text
    .globl main
    .extern fopen
    .extern fclose
    .extern fseek
    .extern ftell
    .extern fgetc
    .extern puts
    .extern exit

main:
    addi sp, sp, -48             # sp = local stack frame
    li t0, 0                     # t0 = answer flag
    sd t0, 0(sp)                 # [sp+0] = answer flag

    la a0, fname                 # a0 = file name
    la a1, readmode              # a1 = open mode
    call fopen
    sd a0, 8(sp)                 # [sp+8] = file handle

    ld a0, 8(sp)                 # a0 = file handle
    li a1, 0                     # a1 = offset 0
    li a2, 2                     # a2 = SEEK_END
    call fseek

    ld a0, 8(sp)                 # a0 = file handle
    call ftell

    li t0, 0                     # t0 = left index
    sd t0, 16(sp)                # [sp+16] = left index
    addi t1, a0, -1              # t1 = right index
    sd t1, 24(sp)                # [sp+24] = right index

pal_loop:
    ld t0, 16(sp)                # t0 = left index
    ld t1, 24(sp)                # t1 = right index
    bge t0, t1, mark_yes         # left >= right means done

    ld a0, 8(sp)                 # a0 = file handle
    mv a1, t0                    # a1 = left index
    li a2, 0                     # a2 = SEEK_SET
    call fseek

    ld a0, 8(sp)                 # a0 = file handle
    call fgetc
    sd a0, 32(sp)                # [sp+32] = left char

    ld a0, 8(sp)                 # a0 = file handle
    ld a1, 24(sp)                # a1 = right index
    li a2, 0                     # a2 = SEEK_SET
    call fseek

    ld a0, 8(sp)                 # a0 = file handle
    call fgetc
    ld t2, 32(sp)                # t2 = left char
    bne t2, a0, close_and_print  # mismatch -> print No

    ld t0, 16(sp)                # t0 = left index
    addi t0, t0, 1               # t0 = next left index
    sd t0, 16(sp)                # [sp+16] = left index

    ld t1, 24(sp)                # t1 = right index
    addi t1, t1, -1              # t1 = next right index
    sd t1, 24(sp)                # [sp+24] = right index
    beq x0, x0, pal_loop

mark_yes:
    li t0, 1                     # t0 = answer flag
    sd t0, 0(sp)                 # [sp+0] = answer flag

close_and_print:
    ld a0, 8(sp)                 # a0 = file handle
    call fclose

    ld t0, 0(sp)                 # t0 = answer flag
    beqz t0, print_no            # t0 = 0 means No
    la a0, affirmative           # a0 = "Yes"
    call puts
    li a0, 0                     # a0 = exit code
    call exit

print_no:
    la a0, negative              # a0 = "No"
    call puts
    li a0, 0                     # a0 = exit code
    call exit
