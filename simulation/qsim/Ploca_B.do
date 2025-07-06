onerror {quit -f}
vlib work
vlog -work work Ploca_B.vo
vlog -work work Ploca_B.vt
vsim -novopt -c -t 1ps -L cycloneii_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.Ploca_B_vlg_vec_tst
vcd file -direction Ploca_B.msim.vcd
vcd add -internal Ploca_B_vlg_vec_tst/*
vcd add -internal Ploca_B_vlg_vec_tst/i1/*
add wave /*
run -all
