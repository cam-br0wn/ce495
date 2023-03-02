

#add wave -noupdate -group cordic_tb
#add wave -noupdate -group cordic_tb -radix hexadecimal /cordic_tb/*

add wave -noupdate -group cordic_tb/cordic_top_inst
add wave -noupdate -group cordic_tb/cordic_top_inst -radix hexadecimal /cordic_tb/cordic_top_inst/*

add wave -noupdate -group cordic_tb/cordic_top_inst/theta_fifo
add wave -noupdate -group cordic_tb/cordic_top_inst/theta_fifo -radix hexadecimal /cordic_tb/cordic_top_inst/theta_fifo/*

add wave -noupdate -group cordic_tb/cordic_top_inst/cordic_inst
add wave -noupdate -group cordic_tb/cordic_top_inst/cordic_inst -radix hexadecimal /cordic_tb/cordic_top_inst/cordic_inst/*

add wave -noupdate -group cordic_tb/cordic_top_inst/cos_fifo
add wave -noupdate -group cordic_tb/cordic_top_inst/cos_fifo -radix hexadecimal /cordic_tb/cordic_top_inst/cos_fifo/*

add wave -noupdate -group cordic_tb/cordic_top_inst/sin_fifo
add wave -noupdate -group cordic_tb/cordic_top_inst/sin_fifo -radix hexadecimal /cordic_tb/cordic_top_inst/sin_fifo/*
