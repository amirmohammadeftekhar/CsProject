.data
    prompt: .asciiz "Input an integer x:\n"
    result: .asciiz "Result(x) = "
.text
main:
    li        $v0, 4
    la        $a0, prompt
    syscall
    li        $v0, 5
    syscall
    move      $a0, $v0
    move      $t9, $v0
    jal      factorial
    move      $t0, $v0
    move      $a0, $t9
    jal      fibonacci
    move      $t1, $v0
    sub	      $t0, $t0, $t1
    li        $v0, 4
    la        $a0, result
    syscall
    li        $v0, 1
    move      $a0, $t0
    syscall
    li        $v0, 10
    syscall


.text
factorial:
    addi    $sp, $sp, -8
    sw      $s0, 4($sp)
    sw      $ra, 0($sp)
    bne     $a0, 0, else
    addi    $v0, $zero, 1
    j fact_return

else:
    move    $s0, $a0
    addi    $a0, $a0, -1
    jal     factorial
    multu   $s0, $v0
    mflo    $v0
fact_return:
    lw      $s0, 4($sp)
    lw      $ra, 0($sp)
    addi    $sp, $sp, 8
    jr      $ra

fibonacci:
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)
    move $s0, $a0
    li $v0, 1
    ble $s0, 0x2, fibonacciExit
    addi $a0, $s0, -1
    jal fibonacci
    move $s1, $v0
    addi $a0, $s0, -2
    jal fibonacci
    add $v0, $s1, $v0
fibonacciExit:
    lw $ra, 8($sp)
    lw $s0, 4($sp)
    lw $s1, 0($sp)
    addi $sp, $sp, 12
    jr $ra
