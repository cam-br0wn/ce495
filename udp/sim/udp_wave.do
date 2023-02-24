

#add wave -noupdate -group udp_tb
#add wave -noupdate -group udp_tb -radix hexadecimal /udp_tb/*

add wave -noupdate -group udp_tb/udp_inst
add wave -noupdate -group udp_tb/udp_inst -radix hexadecimal /udp_tb/udp_inst/*

add wave -noupdate -group udp_tb/udp_inst/input_fifo
add wave -noupdate -group udp_tb/udp_inst/input_fifo -radix hexadecimal /udp_tb/udp_inst/input_fifo/*

add wave -noupdate -group udp_tb/udp_inst/parser
add wave -noupdate -group udp_tb/udp_inst/parser -radix hexadecimal /udp_tb/udp_inst/parser/*

add wave -noupdate -group udp_tb/udp_inst/output_fifo
add wave -noupdate -group udp_tb/udp_inst/output_fifo -radix hexadecimal /udp_tb/udp_inst/output_fifo/*

add wave -noupdate -group udp_tb/udp_inst/parser/data_buffer
add wave -noupdate -group udp_tb/udp_inst/parser/data_buffer -radix hexadecimal /udp_tb/udp_inst/parser/data_buffer/*

add wave -noupdate -group udp_tb/udp_inst/input_fifo/data_fifo
add wave -noupdate -group udp_tb/udp_inst/input_fifo/data_fifo -radix hexadecimal /udp_tb/udp_inst/input_fifo/data_fifo/*

add wave -noupdate -group udp_tb/udp_inst/input_fifo/flag_fifo
add wave -noupdate -group udp_tb/udp_inst/input_fifo/flag_fifo -radix hexadecimal /udp_tb/udp_inst/input_fifo/flag_fifo/*