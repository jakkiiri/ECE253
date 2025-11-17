.equ LEDR, 0xFF200000
.equ KEY, 0xFF200050

.global _start
_start:
	li s0, LEDR
	li s1, KEY
	mv s2, zero # This will store the binary number
	
POLL: lw s3, 0(s1) # Keys are here
	# Check keys to branch
	# key = 0 --> bit 0
	addi a0, zero, 1
	beq s3, a0, INIT
	# key = 1 --> bit 1
	addi a0, zero, 2
	beq s3, a0, INCR
	# Key = 2 --> bit 2
	addi a0, zero, 4
	beq s3, a0, DECR
	# Key = 3 --> bit 3
	addi a0, zero, 8
	beq s3, a0, RST
	j POLL
	
INIT: 
	# Initiate number one on the binary display
	addi s2, zero, 1
	sw s2, 0(s0)
	j POLL # Go back to POLL
	
INCR: 
	# Increase number, but check if number is 15
	addi a0, zero, 15
	beq s2, a0, POLL
	addi s2, s2, 1
	sw s2, 0(s0)
	j POLL
	
DECR: 
	# Decrease number, but check if number is 1
	addi a0, zero, 1
	beq s2, a0, POLL
	addi s2, s2, -1
	sw s2, 0(s0)
	j POLL
	
# Need to poll locally in RST and WAIT_INPUT	
RST:
	lw s3, 0(s1)
    	addi s2, zero, 0
    	sw s2, 0(s0)
	beq s3, a0, RST # Check if bit 3 is still pressed
	# Jump to wait input
	j WAIT_INPUT

WAIT_INPUT:
	lw s3, 0(s1)
	# Waits for an input on s3
	beqz s3, WAIT_INPUT
	j INIT

	
	

	


	
	