onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider tb_fir_output_buffer
add wave -noupdate -format Logic /tb_fir_output_buffer/i_clk
add wave -noupdate -format Logic /tb_fir_output_buffer/i_rstb
add wave -noupdate -format Logic /tb_fir_output_buffer/i_write_enable
add wave -noupdate -format Literal -radix unsigned /tb_fir_output_buffer/i_data
add wave -noupdate -format Logic /tb_fir_output_buffer/i_read_request
add wave -noupdate -format Literal -radix hexadecimal /tb_fir_output_buffer/o_data
add wave -noupdate -format Literal -radix hexadecimal /tb_fir_output_buffer/o_test_add
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate -divider fir_output_buffer
add wave -noupdate -format Logic -radix decimal /tb_fir_output_buffer/u_fir_output_buffer/i_clk
add wave -noupdate -format Logic -radix decimal /tb_fir_output_buffer/u_fir_output_buffer/i_rstb
add wave -noupdate -format Logic -radix decimal /tb_fir_output_buffer/u_fir_output_buffer/i_write_enable
add wave -noupdate -format Literal -radix decimal /tb_fir_output_buffer/u_fir_output_buffer/i_data
add wave -noupdate -format Literal -radix unsigned /tb_fir_output_buffer/u_fir_output_buffer/r_write_add
add wave -noupdate -format Logic -radix decimal /tb_fir_output_buffer/u_fir_output_buffer/i_read_request
add wave -noupdate -format Literal -radix decimal /tb_fir_output_buffer/u_fir_output_buffer/o_data
add wave -noupdate -format Literal -radix unsigned /tb_fir_output_buffer/u_fir_output_buffer/o_test_add
add wave -noupdate -format Literal -radix unsigned /tb_fir_output_buffer/u_fir_output_buffer/r_read_add
add wave -noupdate -format Logic -radix decimal /tb_fir_output_buffer/u_fir_output_buffer/w_read_pulse
add wave -noupdate -format Literal -radix decimal /tb_fir_output_buffer/u_fir_output_buffer/output_buffer_mem
TreeUpdate [SetDefaultTree]
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
WaveRestoreZoom {213 ns} {800 ns}
