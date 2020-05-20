onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_fir_test_data_generator/i_clk
add wave -noupdate -format Logic /tb_fir_test_data_generator/i_rstb
add wave -noupdate -format Logic /tb_fir_test_data_generator/i_pattern_sel
add wave -noupdate -format Logic /tb_fir_test_data_generator/i_start_generation
add wave -noupdate -format Literal -radix decimal /tb_fir_test_data_generator/o_data
add wave -noupdate -format Logic /tb_fir_test_data_generator/o_write_enable
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate -format Logic /tb_fir_test_data_generator/u_fir_test_data_generator/i_clk
add wave -noupdate -format Logic /tb_fir_test_data_generator/u_fir_test_data_generator/i_rstb
add wave -noupdate -format Logic /tb_fir_test_data_generator/u_fir_test_data_generator/i_pattern_sel
add wave -noupdate -format Logic /tb_fir_test_data_generator/u_fir_test_data_generator/i_start_generation
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
