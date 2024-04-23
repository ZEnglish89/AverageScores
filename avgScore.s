.data 

orig: .space 100	# In terms of bytes (25 elements * 4 bytes each)
sorted: .space 100

str0: .asciiz "Enter the number of assignments (between 1 and 25): "
str1: .asciiz "Enter score: "
str2: .asciiz "Original scores: "
str3: .asciiz "Sorted scores (in descending order): "
str4: .asciiz "Enter the number of (lowest) scores to drop: "
str5: .asciiz "Average (rounded down) with dropped scores removed: "
newline: .asciiz "\n"
blank: .asciiz " "


.text 

# This is the main program.
# It first asks user to enter the number of assignments.
# It then asks user to input the scores, one at a time.
# It then calls selSort to perform selection sort.
# It then calls printArray twice to print out contents of the original and sorted scores.
# It then asks user to enter the number of (lowest) scores to drop.
# It then calls calcSum on the sorted array with the adjusted length (to account for dropped scores).
# It then prints out average score with the specified number of (lowest) scores dropped from the calculation.
main: 
	addi $sp, $sp -4
	sw $ra, 0($sp)
	li $v0, 4 
	la $a0, str0 
	syscall 
	li $v0, 5	# Read the number of scores from user
	syscall
	move $s0, $v0	# $s0 = numScores
	move $t0, $0
	la $s1, orig	# $s1 = orig
	la $s2, sorted	# $s2 = sorted
loop_in:
	li $v0, 4 
	la $a0, str1 
	syscall 
	sll $t1, $t0, 2
	add $t1, $t1, $s1
	li $v0, 5	# Read elements from user
	syscall
	sw $v0, 0($t1)
	addi $t0, $t0, 1
	bne $t0, $s0, loop_in
	
	move $a0, $s0
	jal selSort	# Call selSort to perform selection sort in original array
	
	li $v0, 4 
	la $a0, str2 
	syscall
	move $a0, $s1	# More efficient than la $a0, orig
	move $a1, $s0
	jal printArray	# Print original scores
	li $v0, 4 
	la $a0, str3 
	syscall 
	move $a0, $s2	# More efficient than la $a0, sorted
	jal printArray	# Print sorted scores
	
	li $v0, 4 
	la $a0, str4 
	syscall 
	li $v0, 5	# Read the number of (lowest) scores to drop
	syscall
	move $a1, $v0
	sub $a1, $s0, $a1	# numScores - drop
	move $a0, $s2 #this should be $s2, if it says $s1 then it's been changed for a test and needs to be changed back before the code is run for real.
	jal calcSum	# Call calcSum to RECURSIVELY compute the sum of scores that are not dropped
	
	addi $sp, $sp, -4
	sw $v0 0($sp)
	
	la $a0, str5
	li $v0, 4
	syscall
	lw $v0, 0($sp)
	addi $sp, $sp, 4
	
	div $v0, $a1
	mflo $a0
	li $v0, 1
	syscall
	
	# Your code here to compute average and print it
	
	lw $ra, 0($sp)
	addi $sp, $sp 4
	li $v0, 10 
	syscall
	
	
# printList takes in an array and its size as arguments. 
# It prints all the elements in one line with a newline at the end.
printArray:
	# Your implementation of printList here	
	addi $t0, $zero, 0
	move $t1, $a1
	move $t2, $a0
PrintLoop: beq $t0, $t1, EndPrint
	lw $a0, 0($t2)
	li $v0, 1
	syscall
	la $a0, blank
	li $v0, 4
	syscall
	addi $t2, $t2, 4
	addi $t0, $t0, 1
	j PrintLoop
EndPrint: la $a0, newline
	li $v0, 4
	syscall
	jr $ra
	
	
# selSort takes in the number of scores as argument. 
# It performs SELECTION sort in descending order and populates the sorted array
selSort:
	# Your implementation of selSort here
	li $t0, 0
	addi $t1, $s0, 0
	add $t2, $zero, $s1 #$t2 is a pointer to the original list.
	add $t3, $zero, $s2 #$t3 is a pointer to the sorted list.
	
CopyLoop: beq $t0, $t1, Copied
	lw $t4, 0($t2)
	sw $t4, 0($t3) #now sorted[i] = original[i]
	addi $t2, $t2, 4
	addi $t3, $t3, 4
	addi $t0, $t0, 1
	j CopyLoop #increment everything and go again.
	
Copied: #this is for once we've copied the list.
	li $t0, 0 #i
	addi $t1, $s0, -1 #len-1
	add $t2, $zero, $s2 # pointer to sorted list.
OuterLoop: beq $t0, $t1, EndSort #while i<len-1

	move $t3, $t0 #maxindex starts at i	
	
	addi $sp, $sp, -12 #push the stack
	
	sw $t0, 0($sp)

	addi $t0, $t0, 1 #i becomes j

	sw $t1, 4($sp)

	addi $t1, $t1, 1 #len-1 becomes len
	
InnerLoop: beq $t0, $t1, BreakInnerLoop
	
	li $t4, 4
	mul $t4, $t0, $t4
	add $t4, $t2, $t4
	lw $t4, 0($t4) #$t4 is equal to sorted[j]
	
	li $t5, 4
	mul $t5, $t5, $t3
	add $t5, $t5, $t2
	lw $t5, 0($t5) #$t5 is now equal to sorted[maxindex]
	
	slt $t6, $t4, $t5
	bne $t6, $zero, Else
	
	move $t3, $t0 #maxindex=j
	
Else: 	addi $t0, $t0, 1
	j InnerLoop
BreakInnerLoop:
	li $t5, 4
	mul $t5, $t5, $t3
	add $t5, $t5, $t2
	lw $t5, 0($t5) #$t5 is now equal to sorted[maxindex]
	sw $t5, 8($sp) #save sorted[maxindex] on the stack.
	
	li $t5, 4
	lw $t0, 0($sp)
	mul $t0, $t0, $t5
	add $t0, $t0, $t2
	lw $t0, 0($t0) #$t0 = sorted[i]
	
	li $t5, 4
	mul $t5, $t5, $t3
	add $t5, $t5, $t2 #$t5 is equal to the address of sorted[maxindex]
	sw $t0, 0($t5) #sorted[i] is saved in the location of sorted[maxindex]
	
	li $t5, 4
	lw $t0, 0($sp)
	mul $t0, $t0, $t5
	add $t0, $t0, $t2 #$t0 is equal to the address of sorted[i]
	
	lw $t5, 8($sp) #retrieve sorted[maxindex]
	sw $t5, 0($t0) #sorted[maxindex] is saved in the location of sorted[i]
	
	lw $t0, 0($sp)
	addi $t0, $t0, 1
	
	lw $t1, 4($sp)
	
	addi $sp, $sp, 12
	
	j OuterLoop
	
	
	
	
EndSort: jr $ra
	
	
# calcSum takes in an array and its size as arguments.
# It RECURSIVELY computes and returns the sum of elements in the array.
# Note: you MUST NOT use iterative approach in this function.
calcSum:
	# Your implementation of calcSum here
	addi $sp, $sp, -8 #push stack to save the original return address and the original length.
	
	sw $ra, 4($sp) #save the original return address.
	sw $a1, 0($sp) #save the original length.
	
	beq $a1, $zero, Empty #if the length of the list is now zero, just return 0 and move on.
	#This needs to be modified to handle <= 0 rather than just == 0.
	
	addi $a1, $a1, -1 #reduce the length by 1 for the next pass.
	jal calcSum #call the next recursion down, now that $a1 has been reduced.
	#$v0 now contains the sum of all the elements aside from the rightmost one.
	
	lw $a1, 0($sp) #recover the original length.
	addi $t0, $zero, 4
	addi $t1, $a1, -1 #$t1 now contains length-1
	mul $t2, $t1, $t0 #t2 now contains the index of sorted[length-1]
	
	add $t2, $t2, $a0 #t2 now contains the address of sorted[length-1]
	
	lw $t3 0($t2) #$t3 now contains the value of sorted[length-1]
	
	add $v0, $v0, $t3 #Add that last element to $v0, which was all that was missing. We are now ready to clean up and return.
	
	j EndSum
	
Empty:	addi $v0, $zero, 0
	j EndSum
	
EndSum:	lw $ra, 4($sp) #recover the original return address.
	addi $sp, $sp, 8 #pop the stack.
	jr $ra
	
