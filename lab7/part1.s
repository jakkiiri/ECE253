# Program that counts consecutive 1’s.
.global _start
.text
_start:
	li sp, 0x20000
	la s2, LIST # Load the memory address into s2
	lw s3, 0(s2)
	addi s4, zero, 0 # Register s4 will hold the result
WHILE: 
	addi a1, zero, -1
	beq s3, a1, END
	add a0, zero, s3 # store s3 in a0
	jal ONES
	blt s4, a0, UPDATE # check if the current length of ones is longer
NEXT:	
	addi s2, s2, 4
	lw s3, 0(s2)
	j WHILE
UPDATE:
	add s4, a0, zero
	j NEXT
	
# ONES Logic
ONES:
	addi sp, sp, -4
	sw ra, 0(sp)
	# t0 will store ones count
	addi t0, zero, 0
	# t1 will store original a0
	add t1, zero, a0
	jal LOOP
	# Go back to WHILE Subroutine
	lw ra, 0(sp)
	addi sp, sp, 4
	jr ra
LOOP:
	beqz a0, DONE
	srli t1, a0, 1
	and a0, a0, t1
	addi t0, t0, 1
	j LOOP
DONE:
	add a0, zero, t0 # Put count into a0
	# return to ONES subroutine
	jr ra
END: j END

.global LIST
.data
LIST:
.word 0x01010100, 0xF0F0F0F0, -1



