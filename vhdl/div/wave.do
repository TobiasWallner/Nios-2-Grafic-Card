onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider testbench
add wave -noupdate /ci_div_tb/TestCase
add wave -noupdate /ci_div_tb/clk
add wave -noupdate /ci_div_tb/reset
add wave -noupdate /ci_div_tb/dataa
add wave -noupdate /ci_div_tb/datab
add wave -noupdate /ci_div_tb/start
add wave -noupdate /ci_div_tb/result
add wave -noupdate /ci_div_tb/n
add wave -noupdate /ci_div_tb/done
add wave -noupdate -divider divider
add wave -noupdate /ci_div_tb/uut/dataa
add wave -noupdate /ci_div_tb/uut/datab
add wave -noupdate /ci_div_tb/uut/result
add wave -noupdate /ci_div_tb/uut/start
add wave -noupdate /ci_div_tb/uut/done
add wave -noupdate /ci_div_tb/uut/n
add wave -noupdate /ci_div_tb/uut/state
add wave -noupdate /ci_div_tb/uut/next_state
add wave -noupdate /ci_div_tb/uut/calc_instruction
add wave -noupdate /ci_div_tb/uut/read_instruction
add wave -noupdate /ci_div_tb/uut/assigned_calculation
add wave -noupdate /ci_div_tb/uut/numerator
add wave -noupdate /ci_div_tb/uut/denominator
add wave -noupdate /ci_div_tb/uut/div_numerator
add wave -noupdate /ci_div_tb/uut/div_denominator
add wave -noupdate /ci_div_tb/uut/div_numerator_previous
add wave -noupdate /ci_div_tb/uut/div_denominator_previous
add wave -noupdate /ci_div_tb/uut/quotient
add wave -noupdate /ci_div_tb/uut/quotient_trimmed
add wave -noupdate /ci_div_tb/uut/pipeline_status
add wave -noupdate /ci_div_tb/uut/pipeline_working_set
add wave -noupdate /ci_div_tb/uut/pipeline_working
add wave -noupdate /ci_div_tb/uut/quotient_ready
add wave -noupdate /ci_div_tb/uut/div_clock_en
add wave -noupdate /ci_div_tb/uut/previous_result
add wave -noupdate /ci_div_tb/uut/pipeline_working_set_zeros
add wave -noupdate -divider fifo
add wave -noupdate /ci_div_tb/uut/fifo_read_data
add wave -noupdate /ci_div_tb/uut/fifo_write_request
add wave -noupdate /ci_div_tb/uut/fifo_read_request
add wave -noupdate /ci_div_tb/uut/fifo_empty
add wave -noupdate /ci_div_tb/uut/fifo/count
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {381010 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 165
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
WaveRestoreZoom {199780 ps} {431600 ps}
