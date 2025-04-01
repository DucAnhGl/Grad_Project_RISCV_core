#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <cstdlib>
#include <string>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <verilated.h>

#define ENABLE_TRACE 1

#if ENABLE_TRACE
    #include <verilated_fst_c.h>
#endif

#include "Vtop.h"

#define MAX_SIM_TIME 2000
vluint64_t sim_time = 0;

vluint64_t br_instr_counter = 0;
vluint64_t br_misses_counter = 0;
vluint64_t total_instruction_counter = 0;
vluint64_t sim_cycle = 0;

// Reset assertion function
void dut_reset (Vtop *dut, vluint64_t &sim_time) {
    dut->rst_ni = 1;
    if(sim_time >= 3 && sim_time < 5){
        dut->rst_ni = 0;
    }
}

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    Vtop *dut = new Vtop;

    // Open log.txt for logging results
    std::ofstream logFile("log.csv", std::ios::app);
    if (!logFile.is_open()) {
        std::cerr << "Error: Could not open log.csv for writing.\n";
        exit(EXIT_FAILURE);
    }

#if ENABLE_TRACE
    Verilated::traceEverOn(true);
    VerilatedFstC *m_trace = new VerilatedFstC;
    dut->trace(m_trace, 4);
    m_trace->open("wave.fst");
#endif

    while ((dut->instr != 0x0000006F) && (sim_time < MAX_SIM_TIME)) {
        dut_reset(dut, sim_time);
        dut->clk_i ^= 1;
        dut->eval();

        #if ENABLE_TRACE
                m_trace->dump(sim_time);
        #endif

        if (dut->clk_i == 1) {
            if (dut->br_instr == 1) br_instr_counter++;
            if (dut->br_misses == 1) br_misses_counter++;
            if (dut->t_instr != 0) total_instruction_counter++;
            sim_cycle++;
        }

        sim_time++;
    }

    double penalty_percent = 0.0;
    if (br_instr_counter > 0) {
        penalty_percent = ((double)br_misses_counter / (double)br_instr_counter) * 100.0;
    }

    double cycle_penalty_percent = 0.0;
    if (br_instr_counter > 0) {
        cycle_penalty_percent = ((double)br_misses_counter * 2 / (double)sim_cycle) * 100.0;
    }

    double ipc = 0.0;
    if (total_instruction_counter > 0) {
        ipc = ((double)total_instruction_counter / (double)sim_cycle);
    }

    // Summary output to both console and log.txt
    std::ostringstream summary;
    summary << std::left;
    summary << "=============================================================\n";
    summary << "                Branch Prediction Statistics\n";
    summary << "-------------------------------------------------------------\n";
    summary << std::setw(30) << "Total Branch Instructions: "    << br_instr_counter             << "\n";
    summary << std::setw(30) << "Total Branch Mispredictions: "  << br_misses_counter            << "\n";
    summary << std::setw(30) << "Percentage predicted: "         << 100 - penalty_percent << "%\n";
    summary << "\n";
    summary << std::setw(30) << "Total Cycles: "                 << sim_cycle                    << "\n";
    summary << std::setw(30) << "Cycle penalties: "              << br_misses_counter * 2        << "\n";
    summary << std::setw(30) << "Cycle penalty percentage: "     << cycle_penalty_percent << "%\n";
    summary << "\n";
    summary << std::setw(30) << "Total Instruction: "            << total_instruction_counter    << "\n";
    summary << std::setw(30) << "IPC: "                          << ipc                          << "\n";
    summary << "=============================================================\n";

#if ENABLE_TRACE
    m_trace->close();
    delete m_trace;
#endif

    std::string summary_str = summary.str();
    std::cout << summary_str;           // Print to terminal

    logFile << std::fixed << std::setprecision(4)
    << ipc << " " << 100 - penalty_percent << std::endl;

    logFile.close();
    delete dut;

    std::cout << "\n\033[32mSimulation done\033[0m\n";
    return EXIT_SUCCESS;
}
