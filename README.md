# AGREE Branch Predictor on pipelined RISC-V

> A simple 5-stage pipelined RISC-V CPU with AGREE Branch Predictor written in SystemVerilog, benchmarking with CoreMark and implementing a simple program on DE10-Standard using Quartus.

---

## Table of Contents


1. [Overview](#overview)  
2. [Features](#features)  
3. [Prerequisites](#prerequisites)  
4. [Directory Structure](#directory-structure)  
5. [Getting Started](#getting-started)  
6. [Notice on Running CoreMark](#notice-on-running-coremark) 
6. [Workflow](#workflow)  
7. [Running on FPGA](#running-on-fpga)  

---

## Overview

This repository implements a 5-stage pipelined RISC-V CPU core with an AGREE branch predictor. It includes:

- SystemVerilog RTL for the CPU and predictor  
- A CoreMark benchmark for performance evaluation  
- Example programs in both Assembly and C  
- An Intel Quartus project to synthesize and program a DE10-Standard FPGA  

---

## Features

- **5-stage pipeline**: IF, ID, EX, MEM, WB  
- **AGREE branch predictor**: built atop a G-share baseline  
- **Benchmarking**: CoreMark v1.0 for throughput measurement  
- **Open-source toolflow**:  
  - Verilator for RTL simulation  
  - RISC-V GNU Toolchain for compilation  
- **FPGA deployment**: Quartus Prime for implementing on DE10-Standard  

---

## Prerequisites

- **OS**: Ubuntu 22.04+  
- **RTL simulation**: Verilator v4.x+  
- **Toolchain**: RISC-V GNU Toolchain
- **FPGA**: Intel Quartus Prime v20.1+  
- **Python**: 3.6+ (helper scripts)  
- **Make**: GNU Make  

---

## Directory Structure

```bash
Grad_Project_RISCV_core/
├── pipelined_5_stage/         # SystemVerilog RTL  
│   ├── 00_src
│       ├── block_reuse        # RISC-V blocks from CompArch 
│       ├── branch             # Branch predictors
│       ├── top_designs        # Top modules for different branch predictors
│   ├── 01_tb                  # Testbench using Verilator
│   ├── 10_sim
│       ├── ...
│       ├── Makefile           # Make scripts
│       ├── bench              # CoreMark and C programs for benchmark
│           ├── RV32IM-CoreMark # CoreMark 
│           ├── application     # Fibonacci and Quicksort application
├── programs/                  # Assembly file for testing
├── programsC/                  # You can safely ignore this
├── quartus/                    # Quartus project folder
│   ├── ...              
│   ├── pipelined_agree_v2      # Able to run on FPGA
├── .gitignore
└── .gitattributes
```
## Getting Started

1. **Clone the repository**  

```bash
git clone https://github.com/DucAnhGl/Grad_Project_RISCV_core.git

cd Grad_Project_RISCV_core
```

2. **Install dependencies**

Verilator and GTKWave
```bash
sudo apt install verilator gtkwave
```

RISC-V GNU Compiler Toolchain
```bash
git clone https://github.com/riscv/riscv-gnu-toolchain
```
```bash
./configure --prefix=/opt/riscv --with-arch=rv32i --with-abi=ilp32 --enable-multilib
make linux
```

3. Adjust Linker Script Path

Before you can run CoreMark or any C program on your CPU, you must update the RAM linker script to match your working directory.  

You can do this by first determining your working directory using the following commands:

```bash
cd pipelined_5_stage/02_sim/bench/RV32IM-CoreMark/src/common/build
```

```bash
pwd
```

Open the file (pipelined_5_stage/02_sim/bench/RV32IM-CoreMark/src/common/ram.lds) and adjust `line 16` to match your directory name:
```bash
/your_pwd/init_asm.o(.text)
```

## Notice on Running CoreMark
The CoreMark application runs in bare-metal mode, so you cannot use `printf()` or return from `main()`. Instead, at the end of your C program you should write:

```c
while (1) { /* halt here */ }
```

Things should be noticed:

- **Since there’s no `printf()` or console output, you can’t directly verify that CoreMark’s internal algorithm steps executed correctly. At present, validation is limited to: Running with ITERATIONS=1 and ensure the core doesn’t hang in an unintended loop.**

- **Confirming that the testbench catches the while(1) as program completion.**  

- **All performance metrics (IPC, prediction accuracy, etc.) are measured entirely by the testbench through counting clock ticks, taken and mispredicted branches. Because the CPU design does not yet include software timers or counters.**


Planned improvements (not yet implemented):

- **Run a golden reference model (e.g., Spike) in parallel and compare instruction traces to spot any mismatches during CoreMark execution.**

- **Integrate a UART module into the CPU so that `printf()` logging can be used from software for on-chip debug and benchmark output.**

## Workflow

```bash
cd pipelined_5_stage/02_sim
```

1. **Clean previous outputs**  
    ```bash
    make clean
    ```

2. **Generate hex file**
    ```bash
    make hex PROGRAM=1-9
    # Generate .hex file from Assembly program
    ```
    or
    ```bash
    make hexc PROGRAM=coremark ITERATIONS=?
    # → Generate .hex file from C program (iteration is 10 by default)
    ```
3. **Build & simulate with your chosen predictor**
    ```bash
    make all PREDICTOR=1-6
    # Choose from 1 (ALWAYS_TAKEN), 2 (TWO_BIT), 3 (GSHARE), 4 (AGREE), 5 (GSHAREV2), 6 (AGREEV2 - our lastest version)
    ```
4. **View waveforms (only if you enabled tracing)**
    ```bash
    make wave
    # In pipelined_5_stage/01_tb/tb_top.cpp, around line 11:
    #define ENABLE_TRACE 1 (not recommended when running CoreMark)
    ```
5. **Run performance sweep & log metrics**
    ```bash
    make log
    # → executes run_sweep.sh and outputs a log.csv of predictor performance with PHT and GHR size from 2^(2) to 2^(12)
    ```



## Running on FPGA

When running on FPGA, you need to transfer read-only data from the directory `pipelined_5_stage/02_sim/dmem` and map it to the `ram0` through `ram4` in the `quartus/pipelined_two_bit/02_dmemdata` folder. This data should be in Intel HEX format.