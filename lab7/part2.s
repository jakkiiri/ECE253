.global _start
.text
_start:
	la s2, LIST
	# Extract the List Length
	lw s4, 0(s2)
	addi s4, s4, -1
	addi s2, s2, 4
LOOP1:
	beqz s4, END
	add s1, zero, s4
	addi s4, s4, -1
	# Duplicate the pointer
	add a0, zero, s2
LOOP2:
	beqz s1, LOOP1
	jal SWAP
	addi a0, a0, 4
	addi s1, s1, -1
	j LOOP2
SWAP:
	lw t0, 0(a0)
	lw t1, 4(a0)
	blt t1, t0, SWAPOP
	jr ra
SWAPOP:
	# Swap Elements
	sw t1, 0(a0)
	sw t0, 4(a0)
	jr ra
END: j END
	
.global LIST
.data
LIST:
.word 10, 1400, 45, 23, 5, 3, 8, 17, 4, 20, 33
