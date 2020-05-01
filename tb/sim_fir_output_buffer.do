
vcom  -work work ../fir_output_buffer.vhd

vcom -work work -O0 ./tb_fir_output_buffer.vhd

vsim work.tb_fir_output_buffer -novopt -t ns

do wave_fir_output_buffer.do