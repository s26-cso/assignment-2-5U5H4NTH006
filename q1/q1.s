.text
.globl make_node
.globl insert
.globl get
.globl getAtMost
.extern malloc

#   val   = 0
#   left  = 8
#   right = 16

make_node:
    addi sp, sp, -16
    sd ra, 8(sp)
    sw a0, 4(sp)                 # save val for malloc

    li a0, 24                    # sizeof(struct Node)
    call malloc

    lw t0, 4(sp)
    sw t0, 0(a0)                 # node->val = val
    sd x0, 8(a0)                 # node->left = NULL
    sd x0, 16(a0)                # node->right = NULL

make_node_done:
    ld ra, 8(sp)
    addi sp, sp, 16
    ret

get:
get_loop:
    beqz a0, get_not_found       # hit NULL, not here
    lw t0, 0(a0)                 # current node value
    beq t0, a1, get_done
    blt a1, t0, get_left         # smaller -> left

    ld a0, 16(a0)                # else go right
    beq x0, x0, get_loop

get_left:
    ld a0, 8(a0)                 # go left
    beq x0, x0, get_loop

get_not_found:
    li a0, 0

get_done:
    ret

insert:
    addi sp, sp, -32
    sd ra, 24(sp)
    sd s0, 16(sp)
    sd s1, 8(sp)
    sd s2, 0(sp)

    mv s0, a0                    # old root
    mv s1, a1                    # val to insert
    beqz a0, insert_make_root    # empty tree

insert_loop:
    lw t0, 0(a0)                 # cur val
    beq t0, s1, insert_return_root
    blt s1, t0, insert_try_left  # smaller -> left

    ld t1, 16(a0)                # check right
    beqz t1, insert_attach_right
    mv a0, t1
    beq x0, x0, insert_loop

insert_try_left:
    ld t1, 8(a0)                 # check left
    beqz t1, insert_attach_left
    mv a0, t1
    beq x0, x0, insert_loop

insert_attach_left:
    mv s2, a0                    # save parent
    mv a0, s1
    call make_node
    sd a0, 8(s2)                 # parent->left = new node
    mv a0, s0                    # return old root
    beq x0, x0, insert_done

insert_attach_right:
    mv s2, a0
    mv a0, s1
    call make_node
    sd a0, 16(s2)                # parent->right = new node
    mv a0, s0
    beq x0, x0, insert_done

insert_make_root:
    mv a0, s1                    # first node = root
    call make_node
    beq x0, x0, insert_done

insert_return_root:
    mv a0, s0                    # dup, keep old root

insert_done:
    ld s2, 0(sp)
    ld s1, 8(sp)
    ld s0, 16(sp)
    ld ra, 24(sp)
    addi sp, sp, 32
    ret

getAtMost:
    mv t2, a0                    # target val
    mv t3, a1                    # cur node
    li t1, -1                    # best so far

gam_loop:
    beqz t3, gam_done
    lw t0, 0(t3)                 # cur val
    beq t0, t2, gam_exact        # exact hit
    blt t2, t0, gam_left         # too big, go left

    mv t1, t0                    # good hit, try closer on right
    ld t3, 16(t3)
    beq x0, x0, gam_loop

gam_left:
    ld t3, 8(t3)
    beq x0, x0, gam_loop

gam_exact:
    mv a0, t0
    ret

gam_done:
    mv a0, t1
    ret
