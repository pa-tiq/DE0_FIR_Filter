
vcom  -work work ../fir_filter.vhd
vcom  -work work ../fir_filter_test.vhd
vcom  -work work ../fir_output_buffer.vhd

vcom -work work -O0 ./tb_fir_filter_test.vhd

vsim work.tb_fir_filter_test -novopt -t ns

do wave_fir_filter_test.do
