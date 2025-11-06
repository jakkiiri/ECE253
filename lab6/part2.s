# Program that counts consecutive 1’s.
.global _start
.text
_start:
	la s2, LIST # Load the memory address into s2
	lw s3, 0(s2)
	addi s4, zero, 0 # Register s4 will hold the result
	LOOP:
		beqz s3, END # Loop until data contains no more 1’s
		srli s2, s3, 1 # Perform SHIFT, followed by AND
		and s3, s3, s2
		addi s4, s4, 1 # Count the string lengths so far
	j LOOP
END: j END

.global LIST
.data
LIST:
.word 0x103fe00f

