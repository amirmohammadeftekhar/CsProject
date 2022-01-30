.data
    prompt: .asciiz "Input an integer x:\n"
    result: .asciiz "Result(x) = "
.text
main:
    # show prompt
    li        $v0, 4
    la        $a0, prompt
    syscall
    # read x
    li        $v0, 5
    syscall
    # function call fact
    move      $a0, $v0
    move      $t9, $v0
    jal      factorial       # jump factorial and save position to $ra
    move      $t0, $v0        # $t0 = $v0
    # function call fib
    move      $a0, $t9
    jal      fibonacci       # jump factorial and save position to $ra
    move      $t1, $v0        # $t1 = $v0
    # Subtract
    sub	      $t0, $t0, $t1
    # show prompt
    li        $v0, 4
    la        $a0, result
    syscall
    # print the result
    li        $v0, 1        # system call #1 - print int
    move      $a0, $t0        # $a0 = $t0
    syscall                # execute
    # return 0
    li        $v0, 10        # $v0 = 10
    syscall


.text
factorial:
    # base case -- still in parent's stack segment
    # adjust stack pointer to store return address and argument
    addi    $sp, $sp, -8
    # save $s0 and $ra
    sw      $s0, 4($sp)
    sw      $ra, 0($sp)
    bne     $a0, 0, else
    addi    $v0, $zero, 1    # return 1
    j fact_return

else:
    # backup $a0
    move    $s0, $a0
    addi    $a0, $a0, -1 # x -= 1
    jal     factorial
    # when we get here, we already have Fact(x-1) store in $v0
    multu   $s0, $v0 # return x*Fact(x-1)
    mflo    $v0
fact_return:
    lw      $s0, 4($sp)
    lw      $ra, 0($sp)
    addi    $sp, $sp, 8
    jr      $ra

fibonacci:
# Prologue
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)
    move $s0, $a0
    li $v0, 1 # return value for terminal condition
    ble $s0, 0x2, fibonacciExit # check terminal condition
    addi $a0, $s0, -1 # set args for recursive call to f(n-1)
    jal fibonacci
    move $s1, $v0 # store result of f(n-1) to s1
    addi $a0, $s0, -2 # set args for recursive call to f(n-2)
    jal fibonacci
    add $v0, $s1, $v0 # add result of f(n-1) to it
fibonacciExit:
    # Epilogue
    lw $ra, 8($sp)
    lw $s0, 4($sp)
    lw $s1, 0($sp)
    addi $sp, $sp, 12
    jr $ra
    ## End of function fibonacci
