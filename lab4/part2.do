# ModelSim do file for part2 (Rate_divider + DisplayCounter)
# Extended run times because CLOCK_FREQUENCY stays at 500 (much slower Enable pulses).
# We scale the original short runs by ~64 (500/8 ≈ 62.5) to observe multiple Enable pulses.

transcript on

if { [file exists work ] } { vdel -all }
vlib work
vmap work work

vlog -sv part2.sv

# Keep default CLOCK_FREQUENCY=500
vsim -novopt work.part2

# Waves
add wave -divider TOP
add wave sim:/part2/ClockIn
add wave sim:/part2/Reset
add wave sim:/part2/Speed
add wave sim:/part2/CounterValue
add wave -divider RATE_DIV
add wave sim:/part2/RD/CYCLES
add wave sim:/part2/RD/Q_reg
add wave sim:/part2/RD/Q_next
add wave sim:/part2/EnableDC

# 10ns period clock (100 MHz)
force -repeat 10ns sim:/part2/ClockIn 0 0ns, 1 5ns

# Helper to run N clock cycles (each 10ns)
proc run_cycles {cycles} {
    set t [expr {$cycles * 10}]
    run ${t}ns
}

# Reset
force sim:/part2/Reset 0
force sim:/part2/Speed 2'b00
run_cycles 5
force sim:/part2/Reset 1
run_cycles 10

# For CLOCK_FREQUENCY=500 assume internal divide counts are large.
# Choose cycle counts to capture at least a couple of Enable pulses per Speed.
# Adjust if needed once you see actual CYCLES value in waveform.

# Scenario 1: Speed=00
# Expect fastest Enable; run 2000 cycles
force sim:/part2/Speed 2'b00
run_cycles 2000

# Scenario 2: Speed=01
# Slower; run 12000 cycles
force sim:/part2/Speed 2'b01
run_cycles 12000

# Scenario 3: Speed=10
# Run 24000 cycles
force sim:/part2/Speed 2'b10
run_cycles 24000

# Scenario 4: Speed=11
# Slowest; run 48000 cycles
force sim:/part2/Speed 2'b11
run_cycles 48000

# Back to Speed=00
force sim:/part2/Speed 2'b00
run_cycles 4000
