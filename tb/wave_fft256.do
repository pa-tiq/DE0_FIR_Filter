onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_fft256/clk
add wave -noupdate -format Logic /tb_fft256/reset
add wave -noupdate -format Literal -radix decimal /tb_fft256/xr_in
add wave -noupdate -format Literal -radix decimal /tb_fft256/xi_in
add wave -noupdate -format Literal -radix decimal /tb_fft256/fft_valid
add wave -noupdate -format Literal -radix decimal /tb_fft256/rcount_o
add wave -noupdate -format Literal -radix decimal /tb_fft256/stage_o
add wave -noupdate -format Literal -radix decimal /tb_fft256/gcount_o
add wave -noupdate -format Literal -radix decimal /tb_fft256/i1_o
add wave -noupdate -format Literal -radix decimal /tb_fft256/i2_o
add wave -noupdate -format Literal -radix decimal /tb_fft256/k1_o
add wave -noupdate -format Literal -radix decimal /tb_fft256/k2_o
add wave -noupdate -format Literal -radix decimal /tb_fft256/w_o
add wave -noupdate -format Literal -radix decimal /tb_fft256/dw_o
add wave -noupdate -format Literal -radix decimal /tb_fft256/wo
add wave -noupdate -format Analog-Step -height 100 -radix decimal /tb_fft256/fftr_out
add wave -noupdate -format Analog-Step -height 200 -radix decimal /tb_fft256/ffti
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate -format Logic -radix decimal /tb_fft256/u_fft256/clk
add wave -noupdate -format Logic -radix decimal /tb_fft256/u_fft256/reset
add wave -noupdate -format Literal -radix decimal /tb_fft256/u_fft256/xr_in
add wave -noupdate -format Literal -radix decimal /tb_fft256/u_fft256/xi_in
add wave -noupdate -format Literal -radix decimal /tb_fft256/u_fft256/xr_out
add wave -noupdate -format Literal -radix decimal /tb_fft256/u_fft256/xi_out
add wave -noupdate -format Literal -radix decimal /tb_fft256/u_fft256/fftr
add wave -noupdate -format Literal -radix decimal /tb_fft256/u_fft256/ffti
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
