
setenv LMC_TIMEUNIT -9
vlib work
vmap work work

# udp architecture
vlog -work work "../sv/fifo.sv"
vlog -work work "../sv/cordic_macros.sv"
vlog -work work "../sv/cordic_stage.sv"
vlog -work work "../sv/cordic.sv"
vlog -work work "../sv/cordic_top_level.sv"
vlog -work work "../sv/cordic_tb.sv"

# start basic simulation
vsim -voptargs=+acc +notimingchecks -L work work.cordic_tb -wlf cordic_tb.wlf

do cordic_wave.do

run -all
#quit;