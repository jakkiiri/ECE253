# Compile and load
vlib work
vlog part1.sv
vsim part1

log {/*}
add wave {/*}

# Clock (10 ns period)
force -repeat 10 Clock 0 0, 1 5

# -------------------------------
# CASE 1: Basic detection of 1111
# -------------------------------

force Reset 1
force w 0
run 25ns
force Reset 0
run 20 ns

force w 1
run 40ns   ;# 1111 should trigger z=1

# -------------------------------
# CASE 2: Reset behavior
# -------------------------------
force w 0
run 20ns   ;# Reset/idle

# -------------------------------
# CASE 3: Detect 1101
# -------------------------------
force w 1
run 20ns   ;# 11
force w 0
run 10ns   ;# 110
force w 1
run 10ns   ;# 1101 -> z=1

# -------------------------------
# CASE 4: Overlapping patterns
# Pattern stream: 111101
# Detects 1111 first, then overlap 1101 starting at bit 2
# -------------------------------
force w 1
run 40ns   ;# First 1111 pattern
force w 0
run 10ns
force w 1
run 10ns   ;# 111101 — overlapping detection should trigger twice

# -------------------------------
# CASE 5: Random bits (no trigger)
# -------------------------------
force w 0
run 10ns
force w 1
run 10ns
force w 0
run 10ns
force w 1
run 10ns
force w 0
run 10ns   ;# 01010 — should NOT trigger z

# -------------------------------
# CASE 6: Back-to-back triggers
# 11111101 -> Should trigger 1111 (once), then 1101 (overlap)
# -------------------------------
force w 1
run 60ns
force w 0
run 10ns
force w 1
run 10ns   ;# z should go high twice

# -------------------------------
# CASE 7: Alternating with gaps
# Check if FSM resets properly between patterns
# -------------------------------
force w 0
run 30ns
force w 1
run 10ns
force w 0
run 10ns
force w 1
run 10ns
force w 1
run 10ns
force w 0
run 10ns
force w 1
run 10ns   ;# sporadic — should only detect valid sequences
