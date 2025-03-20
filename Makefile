#Makefile for UVM Testbench
INC = +incdir+../
#SVTB1 = ../testbench.sv  
SVTB = package.sv  
#TB = ../TB/top.sv
work = work #library name
VSIMOPT= -novopt -sva -sv_seed random -l s.log  -assertdebug work.top
VSIMBATCH= -c -do "$(VSIMCOV); run -all; exit"

run_test: lib comp run_sim

run_test_gui: lib comp run_sim gui

lib:
	vlib $(work)
	vmap work $(work)
       
comp:
	vlog  $(SVTB) $(SVTB) $(INC) 

# Run simulation for a specific test
run_sim:
	vsim $(VSIMOPT) -sv_seed random +UVM_TESTNAME=$(TESTCASE) $(VSIMBATCH)
gui:
	vsim $(VSIMOPT) -sv_seed random +UVM_TESTNAME=$(TESTCASE)

sv_cmp: lib comp0

run_gui: lib comp gui  

clean:
	rm -rf $(work) transcript *.log *.wlf 
