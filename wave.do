#create work library
#transcript on
#if {[file exists work]} {
#	vdel -lib work -all
#}
#vlib rtl_work
#vmap work rtl_work
vlib work

#vlog	"./altera_lib/*.v"
vlog	"*.v"
vsim	-voptargs=+acc work.meanfilter_tb    
#vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L work -L work -voptargs="+acc"  meanfilter_tb

# Set the window types
view wave
view structure
view signals
radix unsigned

add wave -divider {meanflter}
add wave meanfilter_tb/i1/*
add wave -divider {meanflter_tb}
add wave meanfilter_tb/*




.main clear

run 