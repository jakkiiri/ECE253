.global LIST
.data
LIST:
.word 1, 2, 3, 5, 0xA, -1

.global _start
.text


_start:
	la s2, LIST
	addi s10, zero, 0
	addi s11, zero, 0
	li t1, -1 # Assign a -1 Value
	
	loop:
		lw t3, 0(s2)
		beq t3, t1, END
		
		add s10, s10, t3
		addi s11, s11, 1
		addi s2, s2, 4
		j loop
END: j END
	
	