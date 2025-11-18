.global _start
.text

.equ LEDR, 0xFF200000
.equ KEYS, 0xFF200050
.equ TIMER, 0xFF202000

# CODE STARTS
_start:
    li s0, LEDR             # address of LED
    li s1, KEYS             # address of Keys
    li s5, TIMER            # address of Timer
    addi s3, zero, 0        # s3 will be the increment register
    addi s4, zero, 0        # s4 will be the register for writing to the LEDs

    # need 25 000 000 ticks for 0.25s per tick
    li t0, 0x7840           # low 16 bits
    li t1, 0x017D           # high 16 bits
    li t2, 6                # 0b0110 to start and continue
    sw t0, 8(s5)            # load the low and high 16 bits
    sw t1, 12(s5)
    sw t2, 4(s5)            # start the timer, with CONT enabled

POLL:
    lw s2, 12(s1)           # get edgecapture information - since any key works, don't need the data register
    bnez s2, UPDATE_INCR    # if any input, go to UPDATE_INCR
CHECK_TIMER:
    lw s6, 0(s5)            # get status register of timer
    andi s7, s6, 1          # isolate the last bit for the timeout bit
    bnez s7, DO_COUNTER     # if timeout is 1, update counter
    j POLL                  # return to poll

UPDATE_INCR:
    sw s2, 12(s1)           # resetting edgecapture by storing s2 (the original input)
    xori s3, s3, 1          # xor s3 (which is either 0 or 1) to get the inverse
    j CHECK_TIMER           # return to POLL cycle and wait for timer

DO_COUNTER:
    add s4, s4, s3         # add prior value (s4) with increment (0 or 1)
    li t0, 256
    bne s4, t0, UPDATE_LED  # if not over 255 (if = 256), update directly
    addi s4, zero, 0        # else, reset to 0
UPDATE_LED:
    sw zero, 0(s5)          # reset timeout in timer
    sw s4, 0(s0)            # update LED
    j POLL