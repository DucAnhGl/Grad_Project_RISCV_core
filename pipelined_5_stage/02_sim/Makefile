#*******************************************************************************
# Creator:        Hai Cao Xuan (cxhai.sdh221@hcmut.edu.vn)
# Description:    makefile
#*******************************************************************************
# Copyright (c) 2022 Hai Cao Xuan
#*******************************************************************************

PREDICTOR ?= 1
ifeq ($(PREDICTOR), 1)
    MACRO = ALWAYS_TAKEN
    PREDICTOR_NAME = "Always Taken"
else ifeq ($(PREDICTOR), 2)
    MACRO = TWO_BIT
    PREDICTOR_NAME = "Two bit"
else ifeq ($(PREDICTOR), 3)
    MACRO = GSHARE
    PREDICTOR_NAME = "GShare"
else ifeq ($(PREDICTOR), 4)
    MACRO = AGREE
    PREDICTOR_NAME = "Agree"
else
    $(error Invalid PREDICTOR: $(PREDICTOR). Choose from 1 (ALWAYSTAKEN), 2 (TWOBITS), 3 (GSHARE), 4 (AGREE))
endif

FILES := -f filelist #$(shell cat filelist)

BUILD_PRESIQUITES=$(shell cat filelist | sed 's/-y//g' | sed 's/ //g')

VERILATOR = verilator
VERILATOR_COV = verilator_coverage

### LINT FLAGS
LINT_FLAGS += --unroll-stmts 999999999
LINT_FLAGS += --unroll-count 999999999
LINT_FLAGS += -Wall --lint-only -sv

### VERILATE FLAGS
# Generate C++ in executable form
VERILATOR_FLAGS += -sv -cc
# Optimize
VERILATOR_FLAGS += --x-initial unique
VERILATOR_FLAGS += --x-assign unique
VERILATOR_FLAGS += -O3 -CFLAGS -DCOVERAGE
# Warn abount lint issues; may not want this on less solid designs
VERILATOR_FLAGS += -Wall
#Disable all style warnings
VERILATOR_FLAGS += -Wno-style
# Extend allowed loop body size
VERILATOR_FLAGS += --unroll-stmts 99999
VERILATOR_FLAGS += --unroll-count 99999
# Enable assertion
VERILATOR_FLAGS += --assert
# Make waveforms
VERILATOR_FLAGS += --trace-fst
VERILATOR_FLAGS += --build -j

# Specify the top module file
TOP ?= top.sv

# Add predictor-specific macro
VERILATOR_FLAGS += -D$(MACRO)

# Input files for Verilator
VERILATOR_INPUT = -f filelist ../01_tb/top.sv --top-module top

.PHONY: help
help:
	@echo "make [option]"
	@echo "\tlint    run lint checks for syntax and violations"
	@echo "\01_tbuild   verilate and build modules"
	@echo "\tsim     run simulation"
	@echo "\twave    open waveforms"
	@echo "\tclean   clean the working folder"
	@echo "\thelp    print this help"

.PHONY: lint
lint:
	@echo
	@echo "<>---------------- LINT CHECK ----------------"
	@$(VERILATOR) $(LINT_FLAGS) $(FILES)

.PHONY: build
build: #instruction_mem.mem #./obj_dir/Vtop 
#./obj_dir/Vtop: #../01_tb/tb_top.cpp ../01_tb/top.sv
	@echo "<>---------------- BUILD ----------------"
	@$(VERILATOR) $(VERILATOR_FLAGS) $(VERILATOR_INPUT) --exe ../01_tb/tb_top.cpp

.PHONY: sim
sim: ./obj_dir/Vtop
	@echo "<>---------------- SIMULATING ----------------"
	@./obj_dir/Vtop +verilator+rand+reset+2

.PHONY: wave
wave: wave.fst
	@echo "<>---------------- WAVEFORMS ----------------"
	@gtkwave wave.fst wave.gtkw

.PHONY: clean
clean:
	@rm -rf obj_dir
	@rm -f *.fst
	@echo "<> CLEAN ---------------------"

.PHONY: all
all: 
	make clean
	@echo "Using Predictor: $(PREDICTOR_NAME)"
	make build
	make sim

PROGRAM ?= 1

.PHONY: hex
hex:
ifeq ($(PROGRAM), 1)
	@riscv32-unknown-elf-as -o asm_output/out.o ../../programs/1_agree_friendly.asm
else ifeq ($(PROGRAM), 2)
	@riscv32-unknown-elf-as -o asm_output/out.o ../../programs/2_bubble_sort.asm
else ifeq ($(PROGRAM), 3)
	@riscv32-unknown-elf-as -o asm_output/out.o ../../programs/3_ten_number_bubble_sort.asm
else ifeq ($(PROGRAM), 4)
	@riscv32-unknown-elf-as -o asm_output/out.o ../../programs/4_gshare_friendly.asm
else ifeq ($(PROGRAM), 5)
	@riscv32-unknown-elf-as -o asm_output/out.o ../../programs/5_Fibonacci.asm
else ifeq ($(PROGRAM), 6)
	@riscv32-unknown-elf-as -o asm_output/out.o ../../programs/6_delay_function.asm
else ifeq ($(PROGRAM), 7)
	@riscv32-unknown-elf-as -o asm_output/out.o ../../programs/7_test_program.asm
else
	$(error Invalid PROGRAM: $(PROGRAM). Choose from 1 to 7)
endif
	@riscv32-unknown-elf-objcopy -O verilog asm_output/out.o instruction_mem.mem
	@riscv32-unknown-elf-objdump -d asm_output/out.o > asm_output/output.asm
	@echo "00 00 00 00" >> instruction_mem.mem
	@echo "Generated hex for Program: $(PROGRAM)"



