
vcom  -work work ../fir_filter_4.vhd
vcom  -work work -O0 ./tb_fir_filter_4.vhd

vsim work.tb_fir_filter_4 -novopt -t ns

do wave.do