onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ci_mul_tb/TestCase
add wave -noupdate /ci_mul_tb/clk
add wave -noupdate /ci_mul_tb/reset
add wave -noupdate /ci_mul_tb/dataa
add wave -noupdate /ci_mul_tb/datab
add wave -noupdate /ci_mul_tb/result
add wave -noupdate /ci_mul_tb/test1_result
add wave -noupdate /ci_mul_tb/test2_result
add wave -noupdate -divider mul
add wave -noupdate /ci_mul_tb/uut/clk
add wave -noupdate /ci_mul_tb/uut/clk_en
add wave -noupdate /ci_mul_tb/uut/reset
add wave -noupdate /ci_mul_tb/uut/dataa
add wave -noupdate /ci_mul_tb/uut/datab
add wave -noupdate /ci_mul_tb/uut/result
add wave -noupdate /ci_mul_tb/uut/internal_mul_result
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {105220 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 62
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
WaveRestoreZoom {10480 ps} {209980 ps}
