setenv LMC_TIMEUNIT -9
vlib work
vmap work work

# compile
vlog -work work "/home/ckb4640/ce495/matmul/matmul.sv"
vlog -work work "/home/ckb4640/ce495/matmul/bram.sv"
vlog -work work "/home/ckb4640/ce495/matmul/bram_block.sv"
vlog -work work "/home/ckb4640/ce495/matmul/matmul_top.sv"
vlog -work work "/home/ckb4640/ce495/matmul/matmul_tb.sv"

# run simulation
vsim -classdebug -voptargs=+acc +notimingchecks -L work work.matmul_tb -wlf matmul.wlf

# wave
add wave -noupdate -group matmul_tb
add wave -noupdate -group matmul_tb -radix hexadecimal /matmul_tb/*
add wave -noupdate -group matmul_tb/mat
add wave -noupdate -group matmul_tb/mat -radix hexadecimal /matmul_tb/mat/*
run -all