.text



main:
	li $a0, 100
	li $v0, 9
	syscall
	move $t0, $v0
	sw $t0, cells

    li $v0, 5
    syscall
	add $s0, $0, $v0
	sll $s0, $s0, 2
	move $a0, $s0			# t = n
	jal solve			# solve(n)

	lw $a0, rt			# print(rt)
	li $v0, 1
	syscall

	li $v0, 10
	syscall



solve:

	addi $sp, $sp, -12
	sw $ra, 0($sp)			# storing $ra for returning to the caller
	sw $a0, 4($sp)
	sw $a1, 8($sp)			# storing values which store return values of F and are overwritten in the function


	move $t0, $a0		# $t0 == i, $a0 == t ==> i = t
	addi $t0, $t0, 4
	lw $t1, cells		# $t1 = cells
	add $t2, $t1, $a0
	lw $t3, 0($t2)		# $t3 = cells[t]
	loop_1:
		slt $t2, $t0, $s0
		beqz $t2, end_loop_1
		add $t2, $t1, $t0
		lw $t4, 0($t2)           # $t4 = cells[i]
		sub $t4, $t4, $t3
		sub $t5, $t0, $a0
		sle $t2, $t4, $0
		beqz $t2, next_1
		sub $t4, $0, $t4
		next_1:
		beqz $t4, return
		seq $t2, $t5, $t4
		bnez $t2, return
		addi $t0, $t0, 4
		j loop_1

	end_loop_1:

	beqz $a0, add_1
	j next_2

	add_1:
		lw $t6, rt
		addi $t6, $t6, 1
		sw $t6, rt
		j return

	next_2:

	move $t0, $0
	subi $a0, $a0, 4
	add $t3, $t1, $a0
	loop_2:
		slt $t2, $t0, $s0
		beqz $t2, end_loop_2
		sw $t0, 0($t3)
		addi $sp, $sp, -16
		sw $a0, 4($sp)
		sw $t0, 8($sp)
		sw $t3, 12($sp)
		jal solve
		lw $a0, 4($sp)
		lw $t0, 8($sp)
		lw $t3, 12($sp)
		addi $sp, $sp, 16
		addi $t0, $t0, 4
		j loop_2

	end_loop_2:

	return:
		lw $ra, 0($sp)
		lw $a0, 4($sp)
		lw $a1, 8($sp)
		addi $sp, $sp, 12
		jr $ra




.data

cells: .word 0
rt: .word 0


