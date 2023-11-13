
VCOM_ARGS=-2008 -work work -suppress 1236
VSIM_ARGS=-msgmode both

VHDL_FILES = my_fifo.vhd

TB_FILES = fifo_tb.vhd
TIME_RESOLUTION = 10ps
TB = fifo_tb

SIM_TIME = -all
WAVE_FILE = wave.do

compile: log

log : $(VHDL_FILES) $(TB_FILES)
	rm -f log
	vlib work | tee log
	for i in $(VHDL_FILES); do \
		vcom $(VCOM_ARGS)  $$i | tee -a log;\
	done;
	for i in $(TB_FILES); do \
		vcom $(VCOM_ARGS) $$i | tee -a log;\
	done;
	@echo "-----------------------------------------"
	@echo "        Error and Warning Summary"
	@echo "-----------------------------------------"
	@cat log | grep 'Warning\|Error'
	@if [[ $$(grep "Error:" -m 1 log) ]]; then \
		echo "Compilation had errors!" \
		exit 1; \
	fi;
	
sim_gui: compile
	vsim -do "vsim $(TB) -t $(TIME_RESOLUTION) $(VSIM_ARGS); do $(WAVE_FILE); run $(SIM_TIME)"

sim: compile
	vsim -do "vsim $(TB) -t $(TIME_RESOLUTION) $(VSIM_ARGS); run $(SIM_TIME); quit"
	
clean:
	rm -f transcript
	rm -f vsim.wlf
	rm -f log
	rm -fr work
	
.PHONY: compile
.PHONY: log
.PHONY: sim_gui
.PHONY: sim
.PHONY: clean
