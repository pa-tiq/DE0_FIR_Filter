onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_fir_filter_test/clk
add wave -noupdate -format Logic /tb_fir_filter_test/reset
add wave -noupdate -format Logic /tb_fir_filter_test/i_pattern_sel
add wave -noupdate -format Logic /tb_fir_filter_test/i_start_generation
add wave -noupdate -format Logic /tb_fir_filter_test/i_read_request
add wave -noupdate -format Literal -radix hexadecimal /tb_fir_filter_test/o_data_buffer
add wave -noupdate -format Literal -radix unsigned /tb_fir_filter_test/o_test_add
add wave -noupdate -format Logic -radix unsigned /tb_fir_filter_test/o_test_add(4)
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate -format Logic -radix unsigned /tb_fir_filter_test/u_fir_filter_test/clk
add wave -noupdate -format Logic -radix unsigned /tb_fir_filter_test/u_fir_filter_test/reset
add wave -noupdate -format Logic -radix unsigned /tb_fir_filter_test/u_fir_filter_test/i_pattern_sel
add wave -noupdate -format Logic -radix unsigned /tb_fir_filter_test/u_fir_filter_test/i_start_generation
add wave -noupdate -format Logic -radix unsigned /tb_fir_filter_test/u_fir_filter_test/i_read_request
add wave -noupdate -format Logic -radix unsigned /tb_fir_filter_test/u_fir_filter_test/state
add wave -noupdate -format Literal -radix hexadecimal /tb_fir_filter_test/u_fir_filter_test/o_data_buffer
add wave -noupdate -format Literal -radix unsigned /tb_fir_filter_test/u_fir_filter_test/o_test_add
add wave -noupdate -format Literal -radix unsigned /tb_fir_filter_test/u_fir_filter_test/coeff
add wave -noupdate -format Literal -radix unsigned /tb_fir_filter_test/u_fir_filter_test/fir_output
add wave -noupdate -format Analog-Step -height 50 -max 63.0 -min -0.0 -radix decimal /tb_fir_filter_test/u_fir_filter_test/w_data_filter
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1995 ns} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 77
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
WaveRestoreZoom {1036 ns} {8475 ns}
