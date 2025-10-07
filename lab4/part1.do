# ModelSim do file for part1.sv testbench-less direct instantiation
# Creates library, compiles design, runs through a sequence of stimuli
# Assumptions:
#   reset is active LOW at flip-flop level (rst_n) but top-level port name is 'reset'.
#   ParallelLoadn active low: 0 = load Data_IN
#   RotateRight = 1 selects right-rotation / arithmetic shift right path
#   ASRight asserted only meaningful when RotateRight=1 (doing right shift)
# Clock period = 10ns

transcript on

# Clean & create work library
if { [file exists work] } { vdel -all } 
vlib work
vmap work work

# Compile design
vlog -sv part1.sv

# Elaborate by creating a simulation with an implicit testbench wrapper
vsim -novopt work.part1

# Add signals to wave
add wave -divider Control
add wave -radix unsigned sim:/part1/clock
add wave sim:/part1/reset
add wave sim:/part1/ParallelLoadn
add wave sim:/part1/RotateRight
add wave sim:/part1/ASRight
add wave -divider Data
add wave -radix hex sim:/part1/Data_IN
add wave -radix bin sim:/part1/Q

# Generate clock (ModelSim requires a comma between value/time pairs)
# Correct syntax: force -repeat <period> <signal> <v0> <t0>, <v1> <t1>
force -repeat 10ns sim:/part1/clock 0 0ns, 1 5ns

# Default forces (inactive / safe)
force sim:/part1/reset 0       ;# assert reset low initially
force sim:/part1/ParallelLoadn 1
force sim:/part1/RotateRight   0
force sim:/part1/ASRight       0
force sim:/part1/Data_IN 4'b0000
run 25ns

# Release reset
force sim:/part1/reset 1
run 10ns

# ============ Scenario 1: Parallel Load pattern 0xA (1010) = negative if MSB=1 ============
force sim:/part1/Data_IN 4'b1010
force sim:/part1/ParallelLoadn 0
run 10ns
# Deassert load
force sim:/part1/ParallelLoadn 1
run 10ns

# ============ Scenario 2: Logical Rotate Right (no ASR) for 5 cycles ============
force sim:/part1/RotateRight 1
force sim:/part1/ASRight 0
run 50ns

# ============ Scenario 3: Arithmetic Shift Right from current state for 5 cycles ============
# Expect MSB to replicate previous MSB each cycle
force sim:/part1/ASRight 1
run 50ns

# ============ Scenario 4: Parallel Load pattern 0x3 (0011) then rotate left (RotateRight=0) ============
force sim:/part1/RotateRight 0
force sim:/part1/ASRight 0
force sim:/part1/ParallelLoadn 0
force sim:/part1/Data_IN 4'b0011
run 10ns
force sim:/part1/ParallelLoadn 1
run 40ns   ;# rotate left 4 cycles

# ============ Scenario 5: Hold load low across multiple clocks (should stay constant) ============
force sim:/part1/ParallelLoadn 0
force sim:/part1/Data_IN 4'b1100
run 30ns
force sim:/part1/ParallelLoadn 1
run 10ns

# ============ Scenario 6: Toggle ASRight while not rotating right (no effect) ============
force sim:/part1/RotateRight 0
force sim:/part1/ASRight 1
run 30ns
force sim:/part1/ASRight 0

# ============ Scenario 7: Mixed sequence ============
# Load 0b1111 then do arithmetic shifts to show sign stays 1
force sim:/part1/ParallelLoadn 0
force sim:/part1/Data_IN 4'b1111
run 10ns
force sim:/part1/ParallelLoadn 1
force sim:/part1/RotateRight 1
force sim:/part1/ASRight 1
run 40ns

# Finish
run 20ns

