.data
    input_msg_a1: .asciiz "enter a1: "
    input_msg_a2: .asciiz "enter a2: "
    input_msg_b1: .asciiz "enter b1: "
    input_msg_b2: .asciiz "enter b2: "
    output_msg_a: .asciiz "r: "
    output_msg_b: .asciiz "b: "
    new_line: .asciiz "\n"
    fone: .float 1
    fzero: .float 0
    
.text
main:
    
    
    
    li $t1,1
    
    la $a0,input_msg_a1
    li $v0,4
    syscall
    
    li $v0,6
    syscall
    mov.s $f14,$f0
    
    la $a0,input_msg_b1
    li $v0,4
    syscall
    
    li $v0,6
    syscall
    mov.s $f16,$f0
    
    la $a0,input_msg_a2
    li $v0,4
    syscall
    
    li $v0,6
    syscall
    mov.s $f18,$f0
    
    la $a0,input_msg_b2
    li $v0,4
    syscall
    
    li $v0,6
    syscall
    mov.s $f20,$f0
    
    mul.s $f22,$f18,$f18
    mul.s $f24,$f20,$f20
    add.s $f22,$f24,$f22 # a2^2+b2^2
    mul.s $f0,$f14,$f18
    mul.s $f2,$f16,$f20
    add.s $f24,$f0,$f2
    mul.s $f0,$f14,$f20
    mul.s $f2,$f16,$f18
    sub.s $f26,$f0,$f2
    div.s $f0,$f24,$f22
    div.s $f2,$f26,$f22
    
    mul.s $f4,$f0,$f0
    mul.s $f6,$f2,$f2
    div.s $f8,$f6,$f4
    add.s $f28,$f4,$f6
    sqrt.s $f28,$f28
    div.s $f4,$f2,$f0
    
    l.s $f6,fzero
    l.s $f10,fone
    l.s $f30,fzero
    add.s $f12,$f10,$f10
    mov.s $f8,$f4
    mul.s $f20,$f4,$f4
    li $t0,20
    li $t1,1
    lop_atan:
        div.s $f14,$f8,$f10
        add.s $f30,$f30,$f14
        mul.s $f8,$f8,$f20
        add.s $f10,$f10,$f12
        neg.s $f8,$f8
        sub $t0,$t0,$t1
        bgt $t0,$zero,lop_atan
    
    
    la $a0,output_msg_a
    li $v0,4
    syscall
    
    mov.s $f12,$f28
    li $v0,2
    syscall
    
    la $a0,new_line
    li $v0,4
    syscall
    
    la $a0,output_msg_b
    li $v0,4
    syscall
    
    mov.s $f12,$f30
    li $v0,2
    syscall
    
    
    
        
        
    li $v0,10
    syscall
            
            
            
            
            
        
    
    
    
    
    
    
