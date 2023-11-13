onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /fifo_tb/TestCase
add wave -noupdate /fifo_tb/clk
add wave -noupdate /fifo_tb/reset
add wave -noupdate -divider data
add wave -noupdate /fifo_tb/write_data
add wave -noupdate /fifo_tb/write_request
add wave -noupdate /fifo_tb/read_data
add wave -noupdate /fifo_tb/read_request
add wave -noupdate -divider status
add wave -noupdate /fifo_tb/full
add wave -noupdate /fifo_tb/empty
add wave -noupdate -divider internal
add wave -noupdate /fifo_tb/uut/count
add wave -noupdate -divider {test vectors}
add wave -noupdate /fifo_tb/test1_write_data
add wave -noupdate /fifo_tb/test2_write_data_1
add wave -noupdate /fifo_tb/test2_write_data_2
add wave -noupdate /fifo_tb/test2_write_data_3
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {85000 ps} 0}
quietly wave cursor active 1
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {210 ns}
