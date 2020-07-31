
vcom  -work work ../fir_filter.vhd
vcom  -work work -O0 ./tb_fir_filter.vhd

vsim work.tb_fir_filter -novopt -t ns

do wave.do