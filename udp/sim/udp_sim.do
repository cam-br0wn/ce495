
setenv LMC_TIMEUNIT -9
vlib work
vmap work work

# udp architecture
vlog -work work "../sv/fifo.sv"
vlog -work work "../sv/fifo_ctrl.sv"
vlog -work work "../sv/parse_udp.sv"
vlog -work work "../sv/udp_top_level.sv"
vlog -work work "../sv/udp_tb.sv"

# start basic simulation
vsim -voptargs=+acc +notimingchecks -L work work.udp_tb -wlf udp_tb.wlf

do udp_wave.do

run -all
#quit;