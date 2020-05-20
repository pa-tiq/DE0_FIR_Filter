vcom -work work ../fir_test_data_generator.vhd
vcom -work work ../edge_detector.vhd

vcom  -work work -O0 ./tb_fir_test_data_generator.vhd

vsim work.tb_fir_test_data_generator -novopt -t ns

do wave_fir_test_data_generator.do
