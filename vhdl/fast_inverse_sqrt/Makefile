
VCOM_ARGS=-2008 -work work -suppress 1236
VSIM_ARGS=-msgmode both

VHDL_FILES = ../mul/ci_mul.vhd \
			inverse_sqrt_newton/inverse_sqrt_newton.vhd \
			ufixpoint_to_ufloat/ufixpoint_to_ufloat.vhd \
			ufloat_to_ufixpoint/ufloat_to_ufixpoint.vhd \
			fast_inverse_sqrt.vhd

TB_FILES = fast_inverse_sqrt_tb.vhd
TIME_RESOLUTION = 10ps
TB = fast_inverse_sqrt_tb

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
	
generate_testvectors:
	g++ generate_testvectors.cpp -std=c++17 -O3 -DNDEBUG -o generate_testvectors.exe
	./generate_testvectors.exe
	
analyse_result:
	g++ analyse_result.cpp -std=c++17 -O3 -DNDEBUG -I ../../blaze -o analyse_result.exe
	./analyse_result.exe
	
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
