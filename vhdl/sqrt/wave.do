onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Testbench
add wave -noupdate /mm_avalon_sqrt_tb/TestCase
add wave -noupdate /mm_avalon_sqrt_tb/clk
add wave -noupdate /mm_avalon_sqrt_tb/reset
add wave -noupdate /mm_avalon_sqrt_tb/address
add wave -noupdate /mm_avalon_sqrt_tb/write
add wave -noupdate /mm_avalon_sqrt_tb/read
add wave -noupdate /mm_avalon_sqrt_tb/writedata
add wave -noupdate /mm_avalon_sqrt_tb/readdata
add wave -noupdate -divider sqrt
add wave -noupdate /mm_avalon_sqrt_tb/uut/state
add wave -noupdate /mm_avalon_sqrt_tb/uut/next_state
add wave -noupdate /mm_avalon_sqrt_tb/uut/read_request
add wave -noupdate /mm_avalon_sqrt_tb/uut/status_request
add wave -noupdate /mm_avalon_sqrt_tb/uut/assigned_calculation
add wave -noupdate /mm_avalon_sqrt_tb/uut/pipeline_status
add wave -noupdate /mm_avalon_sqrt_tb/uut/pipeline_working
add wave -noupdate /mm_avalon_sqrt_tb/uut/sqrt_output_about_to_be_ready
add wave -noupdate /mm_avalon_sqrt_tb/uut/sqrt_output_ready
add wave -noupdate /mm_avalon_sqrt_tb/uut/write_request
add wave -noupdate /mm_avalon_sqrt_tb/uut/sqrt_clock_enable
add wave -noupdate /mm_avalon_sqrt_tb/uut/sqrt_output
add wave -noupdate /mm_avalon_sqrt_tb/uut/fmt_sqrt_output
add wave -noupdate /mm_avalon_sqrt_tb/uut/sqrt_input
add wave -noupdate /mm_avalon_sqrt_tb/uut/sqrt_input_previous
add wave -noupdate /mm_avalon_sqrt_tb/uut/fmt_input_value
add wave -noupdate -divider fifo
add wave -noupdate /mm_avalon_sqrt_tb/uut/fifo_read_data
add wave -noupdate /mm_avalon_sqrt_tb/uut/fifo_write_request
add wave -noupdate /mm_avalon_sqrt_tb/uut/fifo_read_request
add wave -noupdate /mm_avalon_sqrt_tb/uut/fifo_empty
add wave -noupdate /mm_avalon_sqrt_tb/uut/fifo_full
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {30030 ps} 0}
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
WaveRestoreZoom {0 ps} {125790 ps}
