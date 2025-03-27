#*******************************************************************************
# Creator:        
# Description:    makefile
#*******************************************************************************
# Copyright (c) 
#*******************************************************************************
RISCV_PREFIX = /opt/riscv/bin/riscv32-unknown-elf-
CCFLAGS      = -march=rv32i -mabi=ilp32

# Default
TOP 	  ?= top.sv
HW 		  ?= 12
PREDICTOR ?= 1
PROGRAM   ?= 1
TARGET 	  ?= asm_output/out
PADSIZE	  ?= 128k

# RAM files define
INSTRUCTIONS  = instruction_mem_padded.mem
RAM_DIR 	  = dmem
RAM_FILES 	  = $(RAM_DIR)/ram0.mem $(RAM_DIR)/ram1.mem $(RAM_DIR)/ram2.mem $(RAM_DIR)/ram3.mem
DATA_MEM_FILE = data_mem_padded.mem

# Define for C program whilie Compiling
ifeq ($(PROGRAM), test)
    TARGET = bench/test/main
else ifeq ($(PROGRAM), coremark)
    TARGET = bench/RV32IM-CoreMark/build/coremark
else ifeq ($(PROGRAM), test2)
    TARGET = bench/test2/test2
endif

# Define for Predictor whilie Compiling
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
    $(error Invalid PREDICTOR: $(PREDICTOR). Choose from 1 (ALWAYS_TAKEN), 2 (TWO_BIT), 3 (GSHARE), 4 (AGREE), 5 (GSHAREV2), 6 (AGREEV2))
endif


BUILD_PRESIQUITES=$(shell cat filelist | sed 's/-y//g' | sed 's/ //g')

VERILATOR = verilator
VERILATOR_COV = verilator_coverage

### LINT FLAGS
LINT_FLAGS += --unroll-stmts 999999999
LINT_FLAGS += --unroll-count 999999999
LINT_FLAGS += -Wall --lint-only -sv

### VERILATE FLAGS
# Pass HW to Verilator as an overridden parameter
VERILATOR_FLAGS += -GHISTORY_WIDTH=$(HW)
# Generate C++ in executable form
VERILATOR_FLAGS += -sv -cc
# Optimize
VERILATOR_FLAGS += --x-initial unique
VERILATOR_FLAGS += --x-assign unique
VERILATOR_FLAGS += -O3 -CFLAGS -DCOVERAGE
# Warn abount lint issues; may not want this on less solid designs
VERILATOR_FLAGS += -Wall
# Disable all style warnings
VERILATOR_FLAGS += -Wno-style
# Extend allowed loop body size
VERILATOR_FLAGS += --unroll-stmts 99999
VERILATOR_FLAGS += --unroll-count 99999
# Enable assertion
VERILATOR_FLAGS += --assert
# Make waveforms
VERILATOR_FLAGS += --trace-fst
VERILATOR_FLAGS += --build -j
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
build: 
	@echo
	@echo "<>---------------- BUILD ----------------"
	@$(VERILATOR) $(VERILATOR_FLAGS) $(VERILATOR_INPUT) --exe ../01_tb/tb_top.cpp

.PHONY: sim
sim: ./obj_dir/Vtop
	@echo
	@echo "<>---------------- SIMULATING ----------------"
	@./obj_dir/Vtop +verilator+rand+reset+2

.PHONY: wave
wave: wave.fst
	@echo
	@echo "<>---------------- WAVEFORMS ----------------"
	@gtkwave wave.fst wave.gtkw

.PHONY: clean
clean:
	@rm -rf obj_dir
	@rm -f *.fst *.csv
	@rm -f asm_output/*.bin asm_output/*.dump asm_output/*.hex asm_output/*.o asm_output/*.elf
	@rm -f bench/test/*.o bench/test/*.bin bench/test/*.elf bench/test/*.dump bench/test/*.hex
	@rm -rf bench/RV32IM-CoreMark/build/*
	@rm -f $(RAM_FILES) $(DATA_MEM_FILE) instruction_mem.mem instruction_mem_padded.mem startup.o
	@echo "<> --------------- CLEAN ---------------"

.PHONY: all
all:
	@echo "Using Predictor: $(PREDICTOR_NAME)"
	make build
	make sim

.PHONY: hex
hex:
	$(RISCV_PREFIX)as -o startup.o startup.S $(CCFLAGS)
ifeq ($(PROGRAM), 1)
	$(RISCV_PREFIX)as -o asm_output/out.o ../../programs/1_agree_friendly.asm $(CCFLAGS)
else ifeq ($(PROGRAM), 2)
	$(RISCV_PREFIX)as -o asm_output/out.o ../../programs/2_bubble_sort.asm $(CCFLAGS)
else ifeq ($(PROGRAM), 3)
	$(RISCV_PREFIX)as -o asm_output/out.o ../../programs/3_ten_number_bubble_sort.asm $(CCFLAGS)
else ifeq ($(PROGRAM), 4)
	$(RISCV_PREFIX)as -o asm_output/out.o ../../programs/4_gshare_friendly.asm $(CCFLAGS)
else ifeq ($(PROGRAM), 5)
	$(RISCV_PREFIX)as -o asm_output/out.o ../../programs/5_fibonacci.asm $(CCFLAGS)
else ifeq ($(PROGRAM), 6)
	$(RISCV_PREFIX)as -o asm_output/out.o ../../programs/6_delay_function.asm $(CCFLAGS)
else ifeq ($(PROGRAM), 7)
	$(RISCV_PREFIX)as -o asm_output/out.o ../../programs/7_test_program.asm $(CCFLAGS)
else ifeq ($(PROGRAM), 8)
	$(RISCV_PREFIX)as -o asm_output/out.o ../../programs/8_complex_branch.asm $(CCFLAGS)
else ifeq ($(PROGRAM), 9)
	$(RISCV_PREFIX)as -o asm_output/out.o ../../programs/9_lsu_v2_test.asm $(CCFLAGS)
else
	$(error Invalid PROGRAM: $(PROGRAM). Choose from 1 to 9)
endif
	$(RISCV_PREFIX)gcc -nostartfiles -O2 \
		-o asm_output/out.elf \
		-T linker.lds \
		asm_output/out.o startup.o
	$(RISCV_PREFIX)objcopy -O verilog asm_output/out.elf asm_output/out.bin
	make padding
	make hex1
	make hex4
	make dump
	make file
	make ram

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
else ifeq ($(PROGRAM), coremark)
	$(MAKE) -C bench/RV32IM-CoreMark
else ifeq ($(PROGRAM), test2)
	$(RISCV_PREFIX)as -o startup.o startup.S -march=rv32i -mabi=ilp32
	$(RISCV_PREFIX)gcc -nostartfiles -O2 \
		-o bench/test2/test2.elf \
		-T linker.lds \
		bench/test2/test2.c \
		startup.o
	$(RISCV_PREFIX)objcopy -O binary bench/test2/test2.elf bench/test2/test2.bin
else
	$(error Invalid PROGRAM: $(PROGRAM). Choose from 1 to 7)
endif
	make padding
	make hex1
	make hex4
	make dump
	make file
	make ram

.PHONY: log
log:
	./run_sweep.sh
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

ram: $(RAM_FILES)
$(RAM_DIR):
	mkdir -p $(RAM_DIR)

$(DATA_MEM_FILE): $(INSTRUCTIONS)
	sed -n '16385,$$p' $(INSTRUCTIONS) > $(DATA_MEM_FILE)
	sed -i '16385,$$d' $(INSTRUCTIONS)

$(RAM_DIR)/ram0.mem: $(DATA_MEM_FILE) $(RAM_DIR)
	@awk '{ print substr($$1, 7, 2) }' $(DATA_MEM_FILE) > $(RAM_DIR)/ram0.mem

$(RAM_DIR)/ram1.mem: $(DATA_MEM_FILE) $(RAM_DIR)
	@awk '{ print substr($$1, 5, 2) }' $(DATA_MEM_FILE) > $(RAM_DIR)/ram1.mem

$(RAM_DIR)/ram2.mem: $(DATA_MEM_FILE) $(RAM_DIR)
	@awk '{ print substr($$1, 3, 2) }' $(DATA_MEM_FILE) > $(RAM_DIR)/ram2.mem

$(RAM_DIR)/ram3.mem: $(DATA_MEM_FILE) $(RAM_DIR)
	@awk '{ print substr($$1, 1, 2) }' $(DATA_MEM_FILE) > $(RAM_DIR)/ram3.mem

