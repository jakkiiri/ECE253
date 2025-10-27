vlib work 
vlog part2.sv
vsim part2

log {/*}
#adding individual waves
#remember you can use add wave {/*} to add all the waves at once
add wave /part2/clk
add wave /part2/reset
add wave /part2/run
add wave /part2/INSTRin
#add the current and next state from the controlpath
add wave /part2/control/current_state
add wave /part2/control/next_state
#add the other waveforms
add wave /part2/r0in
add wave /part2/r1in
add wave /part2/ain
add wave /part2/rin
add wave /part2/irin
add wave /part2/select
add wave /part2/aluop
add wave /part2/a_out
add wave /part2/r_out
add wave /part2/r0_out
add wave /part2/r1_out
add wave /part2/done

#clock signal
force clk 0, 1 1ns -r 2ns

#reset first
force reset 1
force run 0 
force INSTRin 16'b0000000000000000
run 2ns
force reset 0 
run 1ns

# move instruction
#move i r0, #8 -> r0=8
force INSTRin 16'b0010000000001000
force run 1, 0 2ns
run 4ns

# add instructions
#add i r0, #8 -> r0=16
force INSTRin 16'b0110000000001000
force run 1, 0 2ns
run 8ns

# sub instruction
#sub r1, r0 -> r1=-16 = 16'b1111111111110000
force INSTRin 16'b1001000000000000
force run 1, 0 2ns
run 8ns
#run is now zero; wait one more clock cycle to see what r1 becomes
run 2ns

