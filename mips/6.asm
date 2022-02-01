.data
    input_msg_n: .asciiz "enter integer n: "
    input_msg_m: .asciiz "enter integer m: "
    output_msg: .asciiz "result: "
    new_line: .asciiz "\n"
    
.text
main:
    la $a0,input_msg_n
    li $v0,4
    syscall
    li $v0,5
    syscall
    move $s0,$v0
    
    la $a0,input_msg_m
    li $v0,4
    syscall
    li $v0,5
    syscall
    add $s1,$s0,$v0
    
    li $t1,1
    move $t0,$t1
    move $a0,$s0
    lop_s1:
        ble $a0,$zero pass_s1
        sub $a0,$a0,$t1
        mul $t0,$t0,$s1
        sub $s1,$s1,$t1
        b lop_s1
    pass_s1:

    lop_s0:
        ble $s0,$zero,pass_s0
        div $t0,$t0,$s0
        sub $s0,$s0,$t1
        b lop_s0
    pass_s0:
    
    
    la $a0,output_msg
    li $v0,4
    syscall
    
    li $v0,1
    move $a0,$t0
    syscall
    
    li $v0,10
    syscall