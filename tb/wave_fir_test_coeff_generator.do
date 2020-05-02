onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_fir_test_data_generator/clock
add wave -noupdate -format Logic /tb_fir_test_data_generator/reset
add wave -noupdate -format Logic /tb_fir_test_data_generator/start_generation
add wave -noupdate -format Literal -radix decimal /tb_fir_test_data_generator/coeff
add wave -noupdate -format Logic /tb_fir_test_data_generator/write_enable
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate -format Logic /tb_fir_test_data_generator/u_fir_test_data_generator/clock
add wave -noupdate -format Logic /tb_fir_test_data_generator/u_fir_test_data_generator/reset
add wave -noupdate -format Logic /tb_fir_test_data_generator/u_fir_test_data_generator/start_generation
add wave -noupdate -format Literal -radix decimal /tb_fir_test_data_generator/u_fir_test_data_generator/coeff
add wave -noupdate -format Logic /tb_fir_test_data_generator/u_fir_test_data_generator/write_enable
add wave -noupdate -format Literal /tb_fir_test_data_generator/u_fir_test_data_generator/r_write_counter
add wave -noupdate -format Logic /tb_fir_test_data_generator/u_fir_test_data_generator/r_write_counter_ena

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
configure wave -namecolwidth 229
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {1945 ns}
