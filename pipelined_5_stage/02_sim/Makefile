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
	@rm -f bench/test/*.o bench/test/*.bin bench/test/*.elf bench/test/*.dump bench/test/*.hex
	@echo "<> CLEAN ---------------------"

.PHONY: all
all: 
	make clean
	@echo "Using Predictor: $(PREDICTOR_NAME)"
	make build
	make sim

PROGRAM ?= 1

ifeq ($(PROGRAM), 1)
TARGET       = bench/test/main
PADSIZE		 = 8k
else ifeq ($(PROGRAM), 2)
TARGET       = bench/coremark/coremark
PADSIZE		 = 160k
endif

.PHONY: hex
hex: 
ifeq ($(PROGRAM), 1)
# create startup.o file
	@riscv32-unknown-elf-as -o startup.o startup.S -march=rv32i -mabi=ilp32
# create elf file
	@riscv32-unknown-elf-gcc -nostartfiles -O2 \
		-o bench/test/main.elf \
		-T linker.lds \
		bench/test/main.c bench/test/simrv.c bench/test/acker.c bench/test/fib.c bench/test/nqueen.c bench/test/qsort.c \
		startup.o
# create bin file
	@riscv32-unknown-elf-objcopy -O binary bench/test/main.elf bench/test/main.bin
# padding bin file
	make padding
# create hex file
	make hex1
	make hex4
# create asm dump	
	make dump
# create instruction mem
	make file
else ifeq ($(PROGRAM), 2)
# create startup.o file
	@riscv32-unknown-elf-as -o startup.o startup.S -march=rv32i -mabi=ilp32
# create elf file
	@riscv32-unknown-elf-gcc -nostartfiles -O2 \
 		-o bench/coremark/coremark.elf \
 		-T linker.lds \
 		bench/coremark/core_list_join.c bench/coremark/core_main.c bench/coremark/core_matrix.c bench/coremark/core_state.c bench/coremark/core_util.c \
 		bench/coremark/simple/core_portme.c \
		startup.o \
 		-DPERFORMANCE_RUN=1 -DITERATIONS=10 -DFLAGS_STR="\"-o3\""
# create bin file
	@riscv32-unknown-elf-objcopy -O binary bench/coremark/coremark.elf bench/coremark/coremark.bin
# padding bin file
	make padding
# create hex file
	make hex1
	make hex4
# create asm dump	
	make dump
# create instruction mem
	make file
	
else
	$(error Invalid PROGRAM: $(PROGRAM). Choose from 1 to 9)
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

