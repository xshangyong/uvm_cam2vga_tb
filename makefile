

all: comp


TEST_CASE = $(CASE)
UVM_VERBOSITY =	UVM_LOW
N_ERRS = 0
N_FATALS = 0

UVM_HOME	= ../uvm
VCS =	vcs -full64 -sverilog -timescale=1ns/1ns \
			-CFLAGS -DVCS +acc +vpi  \
			+define+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR \
			+incdir+.+./tb+$(UVM_HOME)/src \
			$(UVM_HOME)/src/uvm.sv \
			$(UVM_HOME)/src/dpi/uvm_dpi.cc \
#			 -debug_all \
	

SIMV = 	./simv +UVM_VERBOSITY=$(UVM_VERBOSITY) -l vcs.log +UVM_TESTNAME=$(TEST_CASE)

URG  = urg -format text -dir simv.vdb

CHECK = \
	@$(TEST) \( `grep -c 'UVM_ERROR :    $(N_ERRS)' vcs.log` -eq 1 \) -a \
		 \( `grep -c 'UVM_FATAL :    $(N_FATALS)' vcs.log` -eq 1 \)

comp:
	$(VCS) 	./tb/top_tb.sv \
			./dut/*.v
run:
	$(SIMV)
	$(CHECK)
	
	
clean:
	rm -rf *~ core csrc simv* vc_hdrs.h ucli.key urg* *.log








