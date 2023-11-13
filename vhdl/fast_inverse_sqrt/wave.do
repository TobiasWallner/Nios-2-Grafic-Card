onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Test Bench}
add wave -noupdate /fast_inverse_sqrt_tb/clk
add wave -noupdate /fast_inverse_sqrt_tb/reset
add wave -noupdate /fast_inverse_sqrt_tb/value_in
add wave -noupdate /fast_inverse_sqrt_tb/value_out
add wave -noupdate /fast_inverse_sqrt_tb/value_expected
add wave -noupdate -divider {sqrt constants}
add wave -noupdate /fast_inverse_sqrt_tb/uut/fixpoint_width
add wave -noupdate /fast_inverse_sqrt_tb/uut/point_position
add wave -noupdate /fast_inverse_sqrt_tb/uut/mantissa_width
add wave -noupdate /fast_inverse_sqrt_tb/uut/exponent_width
add wave -noupdate -radix unsigned /fast_inverse_sqrt_tb/uut/wtf_number
add wave -noupdate -divider sqrt
add wave -noupdate /fast_inverse_sqrt_tb/uut/value_in
add wave -noupdate /fast_inverse_sqrt_tb/uut/x2
add wave -noupdate /fast_inverse_sqrt_tb/uut/float_in
add wave -noupdate /fast_inverse_sqrt_tb/uut/float_in_rshift
add wave -noupdate /fast_inverse_sqrt_tb/uut/float_y0
add wave -noupdate /fast_inverse_sqrt_tb/uut/y0
add wave -noupdate -divider fix_to_float
add wave -noupdate /fast_inverse_sqrt_tb/uut/fix_to_float/fixpoint_in
add wave -noupdate /fast_inverse_sqrt_tb/uut/fix_to_float/mantissa
add wave -noupdate -radix unsigned /fast_inverse_sqrt_tb/uut/fix_to_float/exponent
add wave -noupdate /fast_inverse_sqrt_tb/uut/fix_to_float/exponent
add wave -noupdate /fast_inverse_sqrt_tb/uut/fix_to_float/float_out
add wave -noupdate -divider float_to_fix
add wave -noupdate /fast_inverse_sqrt_tb/uut/float_to_fix/float_in
add wave -noupdate -radix unsigned /fast_inverse_sqrt_tb/uut/float_to_fix/exponent
add wave -noupdate /fast_inverse_sqrt_tb/uut/float_to_fix/exponent
add wave -noupdate /fast_inverse_sqrt_tb/uut/float_to_fix/mantissa
add wave -noupdate /fast_inverse_sqrt_tb/uut/float_to_fix/fixpoint_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {34580 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 279
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
WaveRestoreZoom {0 ps} {206540 ps}
