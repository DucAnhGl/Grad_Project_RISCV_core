#*******************************************************************************
# Creator:        Hai Cao Xuan (cxhai.sdh221@hcmut.edu.vn)
# Description:    makefile
#*******************************************************************************
# Copyright (c) 2022 Hai Cao Xuan
#*******************************************************************************
RISCV_PREFIX = /opt/riscv/bin/riscv32-unknown-elf-
CCFLAGS      = -O2 -march=rv32i -mabi=ilp32

.SUFFIXES: .o .c .S

PREDICTOR ?= 1

ifeq ($(PREDICTOR), 1)
    MACRO = ALWAYS_TAKEN
    PREDICTOR_NAME = "Always Taken"
    FILELIST = filelist/filelist1
else ifeq ($(PREDICTOR), 2)
    MACRO = TWO_BIT
    PREDICTOR_NAME = "Two Bit"
    FILELIST = filelist/filelist2
else ifeq ($(PREDICTOR), 3)
    MACRO = GSHARE
    PREDICTOR_NAME = "GShare"
    FILELIST = filelist/filelist3
else ifeq ($(PREDICTOR), 4)
    MACRO = AGREE
    PREDICTOR_NAME = "Agree"
    FILELIST = filelist/filelist4
else ifeq ($(PREDICTOR), 5)
    MACRO = GSHAREv2
    PREDICTOR_NAME = "GSHAREv2"
    FILELIST = filelist/filelist5
else ifeq ($(PREDICTOR), 6)
    MACRO = AGREEv2
    PREDICTOR_NAME = "AGREEv2"
    FILELIST = filelist/filelist6
else
    $(error Invalid PREDICTOR: $(PREDICTOR). Choose from 1 (ALWAYS_TAKEN), 2 (TWO_BIT), 3 (GSHARE), 4 (AGREE))
endif

# FILES := -f $(FILELIST) #$(shell cat filelist)

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
VERILATOR_INPUT = -f $(FILELIST) ../01_tb/top.sv --top-module top

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
	@$(VERILATOR) $(LINT_FLAGS) -f $(FILELIST)

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
	@rm -f asm_output/output.asm asm_output/out.o startup.o
	@rm -f bench/test/*.o bench/test/*.bin bench/test/*.elf bench/test/*.dump bench/test/*.hex
	@rm -rf bench/RV32IM-CoreMark/build/*
	@rm -f $(RAM_FILES) $(DATA_MEM_FILE) instruction_mem.mem instruction_mem_padded.mem
	@echo "<> CLEAN ---------------------"

.PHONY: all
all:
#	make clean
	@echo "Using Predictor: $(PREDICTOR_NAME)"
	make build
	make sim

PROGRAM ?= 1

.PHONY: hex
hex:
ifeq ($(PROGRAM), 1)
	$(RISCV_PREFIX)as -o asm_output/out.o ../../programs/1_agree_friendly.asm
else ifeq ($(PROGRAM), 2)
	$(RISCV_PREFIX)as -o asm_output/out.o ../../programs/2_bubble_sort.asm
else ifeq ($(PROGRAM), 3)
	$(RISCV_PREFIX)as -o asm_output/out.o ../../programs/3_ten_number_bubble_sort.asm
else ifeq ($(PROGRAM), 4)
	$(RISCV_PREFIX)as -o asm_output/out.o ../../programs/4_gshare_friendly.asm
else ifeq ($(PROGRAM), 5)
	$(RISCV_PREFIX)as -o asm_output/out.o ../../programs/5_fibonacci.asm
else ifeq ($(PROGRAM), 6)
	$(RISCV_PREFIX)as -o asm_output/out.o ../../programs/6_delay_function.asm
else ifeq ($(PROGRAM), 7)
	$(RISCV_PREFIX)as -o asm_output/out.o ../../programs/7_test_program.asm
else ifeq ($(PROGRAM), 8)
	$(RISCV_PREFIX)as -o asm_output/out.o ../../programs/8_complex_branch.asm
else ifeq ($(PROGRAM), 9)
	$(RISCV_PREFIX)as -o asm_output/out.o ../../programs/9_lsu_v2_test.asm
else
	$(error Invalid PROGRAM: $(PROGRAM). Choose from 1 to 9)
endif

	@riscv32-unknown-elf-objcopy -O verilog asm_output/out.o instruction_mem.mem
	@riscv32-unknown-elf-objdump -d asm_output/out.o > asm_output/output.asm
	@echo "00 00 00 00" >> instruction_mem.mem
	@echo "Generated hex for Program: $(PROGRAM)"


ifeq ($(PROGRAM), test)
TARGET       = bench/test/main
PADSIZE		 = 128k
else ifeq ($(PROGRAM), coremark)
TARGET       = bench/RV32IM-CoreMark/build/coremark
PADSIZE		 = 128k
else ifeq ($(PROGRAM), test2)
TARGET       = bench/test2/test2
PADSIZE		 = 128k
endif

.PHONY: hexc
hexc:
ifeq ($(PROGRAM), test)
	$(RISCV_PREFIX)as -o startup.o startup.S -march=rv32i -mabi=ilp32
	$(RISCV_PREFIX)gcc -nostartfiles -O2 \
		-o bench/test/main.elf \
		-T linker.lds \
		bench/test/main.c bench/test/simrv.c bench/test/acker.c bench/test/fib.c bench/test/nqueen.c bench/test/qsort.c \
		startup.o
	$(RISCV_PREFIX)objcopy -O binary bench/test/main.elf bench/test/main.bin
	make padding
	make hex1
	make hex4
	make dump
	make file
	make ram
else ifeq ($(PROGRAM), coremark)
	$(MAKE) -C bench/RV32IM-CoreMark
	make padding
	make hex1
	make hex4
	make dump
	make file
	make ram
else ifeq ($(PROGRAM), test2)
	$(RISCV_PREFIX)as -o startup.o startup.S -march=rv32i -mabi=ilp32
	$(RISCV_PREFIX)gcc -nostartfiles -O2 \
		-o bench/test2/test2.elf \
		-T linker.lds \
		bench/test2/test2.c \
		startup.o
	$(RISCV_PREFIX)objcopy -O binary bench/test2/test2.elf bench/test2/test2.bin
	make padding
	make hex1
	make hex4
	make dump
	make file
	make ram
else
	$(error Invalid PROGRAM: $(PROGRAM). Choose from 1 to 7)
endif
	

###############################################################################
padding:
	cp $(TARGET).bin $(TARGET)_.bin
	dd if=/dev/zero bs=$(PADSIZE) count=1 >> $(TARGET)_.bin
	dd if=$(TARGET)_.bin bs=$(PADSIZE) count=1 > $(TARGET).bin
	rm -f $(TARGET)_.bin

dump:
	$(RISCV_PREFIX)objdump -D $(TARGET).elf > $(TARGET).dump

hex1:
	hexdump -v -e '1/1 "%02x" "\n"' $(TARGET).bin > $(TARGET)1.hex

hex4:
	hexdump -v -e '1/4 "%08x" "\n"' $(TARGET).bin > $(TARGET)4.hex

file:
	cp $(TARGET)1.hex instruction_mem.mem
	cp $(TARGET)4.hex instruction_mem_padded.mem
	cp $(TARGET).dump asm_output/output.asm

###############################################################################

# Variables
INSTRUCTIONS = instruction_mem_padded.mem
RAM_DIR = dmem
RAM_FILES = $(RAM_DIR)/ram0.mem $(RAM_DIR)/ram1.mem $(RAM_DIR)/ram2.mem $(RAM_DIR)/ram3.mem
DATA_MEM_FILE = data_mem_padded.mem

# Default target for making the RAM files and data file
ram: $(RAM_FILES)

# Rule to create the dmem directory if it doesn't exist
$(RAM_DIR):
	mkdir -p $(RAM_DIR)

# Rule to create the data_mem_padded.mem file (cut and save lines from 16385 to end)
$(DATA_MEM_FILE): $(INSTRUCTIONS)
	sed -n '16385,$$p' $(INSTRUCTIONS) > $(DATA_MEM_FILE)
	sed -i '16385,$$d' $(INSTRUCTIONS)

# Rule to create the RAM files from data_mem_padded.mem
$(RAM_DIR)/ram0.mem: $(DATA_MEM_FILE) $(RAM_DIR)
	@awk '{ print substr($$1, 7, 2) }' $(DATA_MEM_FILE) > $(RAM_DIR)/ram0.mem

$(RAM_DIR)/ram1.mem: $(DATA_MEM_FILE) $(RAM_DIR)
	@awk '{ print substr($$1, 5, 2) }' $(DATA_MEM_FILE) > $(RAM_DIR)/ram1.mem

$(RAM_DIR)/ram2.mem: $(DATA_MEM_FILE) $(RAM_DIR)
	@awk '{ print substr($$1, 3, 2) }' $(DATA_MEM_FILE) > $(RAM_DIR)/ram2.mem

$(RAM_DIR)/ram3.mem: $(DATA_MEM_FILE) $(RAM_DIR)
	@awk '{ print substr($$1, 1, 2) }' $(DATA_MEM_FILE) > $(RAM_DIR)/ram3.mem

