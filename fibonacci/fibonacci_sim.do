setenv LMC_TIMEUNIT -9
vlib work
vmap work work

# compile
vlog -work work "/home/ckb4640/ce495/fibonacci/fibonacci.sv"
vlog -work work "/home/ckb4640/ce495/fibonacci/fibonacci_tb.sv"

# run simulation
vsim -classdebug -voptargs=+acc +notimingchecks -L work work.fibonacci_tb -wlf fibonacci.wlf

# wave
add wave -noupdate -group fibonacci_tb
add wave -noupdate -group fibonacci_tb -radix hexadecimal /fibonacci_tb/*
add wave -noupdate -group fibonacci_tb/fib
add wave -noupdate -group fibonacci_tb/fib -radix hexadecimal /fibonacci_tb/fib/*
run -all