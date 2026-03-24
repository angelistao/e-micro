export ROOT       = $(CURDIR)
export DESIGN_    = multiplier_wrapper
export FREQ_MHZ   ?= 50
export OP_CORNER  ?= slow
       TESTS_DIR  = ${ROOT}/codes/testbench
export MULT       ?= array

GUI        ?= 0
TB         ?= 1
MUL        ?= 0
GUI        ?= 0
TESTS      ?= 100
export WIDTH      ?= 16
FLAGS += -access +rwc

flist_path = $(CURDIR)/codes/filelists/array_multiplier.flist

ifeq ($(GUI),1)
	FLAGS += -gui
endif

ifneq ($(TESTS),100)
	FLAGS += +define+TESTS_NUM=$(TESTS)
endif

ifneq ($(WIDTH),16)
	FLAGS += +define+WIDTH=$(WIDTH)
endif

ifeq ($(MULT), karatsuba)
	flist_path = $(CURDIR)/codes/filelists/karatsuba_multiplier.flist
else ifeq ($(MULT), standard)
	flist_path = $(CURDIR)/codes/filelists/standard_multiplier.flist
endif


multiplier_xcelium:
	cd synthesis/work && \
	rm -rf * && \
	xrun -64bit -v200x -v93 -file $(flist_path) $(TESTS_DIR)/multiplier_tb.sv $(FLAGS) -top multiplier_tb

multiplier_wrapper_xcelium:
	cd synthesis/work && \
	rm -rf * && \
	xrun -64bit -v200x -v93 -file $(flist_path) $(CURDIR)/synthesis/inputs/multiplier_wrapper.v $(TESTS_DIR)/multiplier_wrapper_tb.sv $(FLAGS) -top multiplier_wrapper_tb

cla_xcelium:
	cd synthesis/work && \
	rm -rf * && \
	xrun -64bit -v200x -v93 $(ROOT)/codes/util/CLA_xBits.vhd $(TESTS_DIR)/CLA_xb_tb.vhd $(FLAGS) -top tb_cla_Xbits

run_logical_synth:
	cd ${ROOT}/synthesis/work && \
	rm -rf * && \
	genus -f $(ROOT)/synthesis/inputs/synth.tcl  -overwrite \