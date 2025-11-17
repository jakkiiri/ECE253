.equ LEDR, 0xFF200000
.equ KEY,  0xFF200050
.equ COUNTER_DELAY, 500000

.global _start
_start:
    li s0, LEDR
    li s1, KEY
    addi t0, zero, 0 # Holds  State, 0 is count, 1 is stop
    addi a0, zero, 0 # This is the counter value 
    
# POLLING
POLL: lw s2, 0(s1) # load input
    # Check if button is pressed (check edge)
    lw s3, 12(s1)      
    # If no edge detected, check previous state to determine behavior
    beqz s3, CHECK_STATE
    # If Edge detected, check cases
    j CHECK_CASE
    
CHECK_STATE:
    beqz t0, UPCOUNT
    j POLL
    
UPCOUNT:
    addi a1, zero, 255
    beq a0, a1, RST
    # Increase a0
    addi a0, a0, 1
    sw a0, 0(s0)        # update led
    # Run the delay loop
    j DO_DELAY

RST:
    # reset counter to zero
    addi a0, zero, 0
    sw a0, 0(s0)        # update led
    j POLL
    
CHECK_CASE:
    beqz t0, STOP_COUNT
    # Continue count logic
    addi t0, zero, 0    # (This is wrong logic, but I keep your code — see below)
    # Reset the edge detect
    sw s3, 12(s1)       
    # Do one instance of check_state
    j CHECK_STATE
    
STOP_COUNT:
    addi t0, zero, 1 # This stops upcount
    # Reset the edge detect
    sw s3, 12(s1)    
    j CHECK_STATE
    
DO_DELAY:
    li t4, COUNTER_DELAY     
SUB_LOOP:
    addi t4, t4, -1
    bnez t4, SUB_LOOP
    # Jump back to POLLING
    j POLL
