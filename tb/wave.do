onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_fir_filter_4/clk
add wave -noupdate -format Logic /tb_fir_filter_4/reset
add wave -noupdate -format Literal -radix decimal /tb_fir_filter_4/i_coeff
add wave -noupdate -format Literal -radix decimal /tb_fir_filter_4/i_data
add wave -noupdate -format Literal -radix decimal /tb_fir_filter_4/o_data
add wave -noupdate -format Analog-Step -height 100 -radix decimal /tb_fir_filter_4/i_data
add wave -noupdate -format Analog-Step -height 100 -radix decimal /tb_fir_filter_4/o_data
add wave -noupdate -format Literal -radix unsigned /tb_fir_filter_4/p_input/control
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate -format Logic -radix decimal /tb_fir_filter_4/u_fir_filter_4/clk
add wave -noupdate -format Logic -radix decimal /tb_fir_filter_4/u_fir_filter_4/reset
add wave -noupdate -format Literal -radix decimal /tb_fir_filter_4/u_fir_filter_4/i_coeff
add wave -noupdate -format Literal -radix decimal /tb_fir_filter_4/u_fir_filter_4/i_data
add wave -noupdate -format Literal -radix decimal /tb_fir_filter_4/u_fir_filter_4/o_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {13466 ns} 0}
configure wave -namecolwidth 150
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ns} {23100 ns}
