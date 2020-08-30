
vcom  -work work ../fft256.vhd

vcom -work work -O0 ./tb_fft256.vhd

vsim work.tb_fft256 -novopt -t ns

do wave_fft256.do
