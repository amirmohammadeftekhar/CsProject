.data
    input_msg_n: .asciiz "enter n: "
    input_msg_coeff: .asciiz "enter coefficient a"
    no_sol_exists_msg: .asciiz "no solution exists"
    root_found_msg: .asciiz "root found: "
    colon: .asciiz ": "
    new_line: .asciiz "\n"
    n: .word 0
    f: .space 400
    df: .space 400
    fzero: .float 0.0
    fone: .float 1.0
    feps: .float 0.01
    x: .float 5.0
    
.text
main:
    
    
    
    l.s $f2,fzero
    l.s $f4,fzero
    l.s $f6,fone
    li $t1,1
    
    la $a0,input_msg_n
    li $v0,4
    syscall
    
    li $v0,5
    syscall
    
    add $v0,$v0,$t1
    sw $v0,n
    li $a1,0
    lw $t0,n
    
    
    input_f:
        li $v0,4
        la $a0,input_msg_coeff
        syscall
        li $v0,1
        add $a0,$a1,$zero
        syscall
        li $v0,4
        la $a0,colon
        syscall
        
        li $v0,6
        syscall 
        li $a3,8
        mul $a2,$a1,$a3
        swc1 $f0,f($a2)
        sub $a2,$a2,$a3
        mul.s $f0,$f0,$f4
        swc1 $f0,df($a2)
        
        add $a1,$a1,$t1
        add.s $f4,$f4,$f6
        blt $a1,$t0,input_f
        
   
   
    
    
    li $a0,30
    loop:
        l.s $f4,x
        li $a1,0
        l.s $f6,fone
        l.s $f8,fzero
        l.s $f10,fzero
        li $a3,0
        lop:
            l.s $f14,f($a1)
            l.s $f16,df($a1)
            mul.s $f12,$f6,$f14
            add.s $f8,$f8,$f12
            mul.s $f12,$f6,$f16
            add.s $f10,$f10,$f12
            
            mul.s $f6,$f6,$f4
            li $a2,8
            add $a1,$a1,$a2
            li $a2,1
            add $a3,$a3,$a2
            lw $a2,n
            blt $a3,$a2,lop

        div.s $f6,$f8,$f10
        sub.s $f4,$f4,$f6
        s.s $f4,x
        sub $a0,$a0,$t1
        bne $a0,$zero,loop
    
    l.s $f4,feps
    abs.s $f8,$f8
    c.lt.s $f4,$f8
    bc1t no_sol
    
    la $a0,root_found_msg
    li $v0,4
    syscall
    
    li $v0,2
    l.s $f12,x
    syscall
    
    li $v0,10
    syscall
    
    no_sol:
    la $a0,no_sol_exists_msg
    li $v0,4
    syscall
    
    li $v0,10
    syscall
            
            
            
            
            
        
    
    
    
    
    
    
