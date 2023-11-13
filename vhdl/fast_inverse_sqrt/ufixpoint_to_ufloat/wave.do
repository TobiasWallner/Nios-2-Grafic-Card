onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {test bench}
add wave -noupdate /ufixpoint_to_ufloat_tb/clk
add wave -noupdate /ufixpoint_to_ufloat_tb/fixpoint
add wave -noupdate /ufixpoint_to_ufloat_tb/float
add wave -noupdate -divider converter
add wave -noupdate /ufixpoint_to_ufloat_tb/uut/fixpoint_in
add wave -noupdate /ufixpoint_to_ufloat_tb/uut/float_out
add wave -noupdate /ufixpoint_to_ufloat_tb/uut/mantissa
add wave -noupdate -radix unsigned /ufixpoint_to_ufloat_tb/uut/exponent
add wave -noupdate -radix unsigned /ufixpoint_to_ufloat_tb/uut/exponent_offset
add wave -noupdate /ufixpoint_to_ufloat_tb/uut/exponent_offset_int
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 264
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
WaveRestoreZoom {0 ps} {189 ns}
