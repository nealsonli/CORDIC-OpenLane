#include <stdlib.h>
#include <iostream>
#include <iomanip>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vcordic.h"
#include "testcase.h"

vluint64_t sim_time = 0;
Vcordic *dut;
VerilatedVcdC *m_trace;

void toggle(){
  dut->i_clk ^= 1;
  dut->eval();
  m_trace->dump(sim_time++);
  dut->i_clk ^= 1;
  dut->eval();
  m_trace->dump(sim_time++);
}

void initialize_signals(){
    dut->i_rst  = 1;
    dut->i_clk  = 0;
    dut->i_vld  = 0;
    dut->i_data = 0;

    for(int i=0;i<5;i++)
      toggle();

    dut->i_rst = 0;

    for(int i=0;i<5;i++)
      toggle();
}

long long compose_i_data(int func, int x, int y, int z){
    return ((long long)func << 48) + ((long long)x << 32) + ((long long)y << 16) + (long long)z;
}

int run_case(){

    // Feed the i_data
    dut->i_vld = 1;
    dut->i_data = compose_i_data(func, x, y, z);
    toggle();
    dut->i_vld = 0;
    toggle();
    
    // Wait for o_vld to become 1
    int wait_cycles = 1;
    while(dut->o_vld != 1){
      toggle();
      wait_cycles++;
    }

    return wait_cycles;
}

int main(int argc, char** argv, char** env) {
    dut = new Vcordic;
    Verilated::traceEverOn(true);
    m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    // Initialize DUT
    initialize_signals();

    // Run some testcases
    printf("\n");
    int wait_cycles = run_case();
    printf("  [Wait cycles] %d cycles\n", wait_cycles);
    printf("  [ Input Data] function = %ld, x = %04ld, y = %04ld, z = %04ld\n", dut->i_data >> 48, (dut->i_data >> 32) & 0xFFFF, (dut->i_data >> 16) & 0xFFFF, (dut->i_data >> 0) & 0xFFFF);
    printf("  [Output Data] function = %ld, x = %04ld, y = %04ld, z = %04ld\n", dut->o_data >> 48, (dut->o_data >> 32) & 0xFFFF, (dut->o_data >> 16) & 0xFFFF, (dut->o_data >> 0) & 0xFFFF);
    printf("\n");

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}