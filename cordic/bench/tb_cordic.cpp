#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <iomanip>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vcordic.h"
#include "testcase.h"

vluint64_t sim_time = 0;
Vcordic *dut;
VerilatedVcdC *m_trace;

using namespace std;

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
    m_trace->open("cordic/simulation/waveform.vcd");

    // Initialize DUT
    initialize_signals();

    // Run some testcases
    printf("\n");
    int wait_cycles = run_case();
    printf("  [Wait Cycles] %d cycles\n", wait_cycles);
    printf("  [ Input Data] function = 0x%lx, x = 0x%04lx, y = 0x%04lx, z = 0x%04lx\n", dut->i_data >> 48, (dut->i_data >> 32) & 0xFFFF, (dut->i_data >> 16) & 0xFFFF, (dut->i_data >> 0) & 0xFFFF);
    printf("  [Output Data] function = 0x%lx, x = 0x%04lx, y = 0x%04lx, z = 0x%04lx\n", dut->o_data >> 48, (dut->o_data >> 32) & 0xFFFF, (dut->o_data >> 16) & 0xFFFF, (dut->o_data >> 0) & 0xFFFF);
    printf("\n");

    int stage_size = sizeof(dut->cordic__DOT__u_cordic_iteration__DOT__cordic_data[0][0]);
    //printf("stage_size: %d\n", stage_size);
    int num_iter_per_stage = sizeof(dut->cordic__DOT__u_cordic_iteration__DOT__cordic_data[0])/stage_size - 1;
    //printf("num_iter_per_stage: %d\n", num_iter_per_stage);
    int iter_size = sizeof(dut->cordic__DOT__u_cordic_iteration__DOT__cordic_data[0]);
    //printf("iter_size: %d\n", iter_size);
    int num_stage = sizeof(dut->cordic__DOT__u_cordic_iteration__DOT__cordic_data)/iter_size;
    //printf("num_stage: %d\n", num_stage);

    // Write the result to file
    ofstream result;
    result.open("cordic/simulation/result");
    //result << hex;
    for(int i=0;i<wait_cycles;i++){
      result << (dut->cordic__DOT__u_cordic_iteration__DOT__cordic_data[i][num_iter_per_stage][2] & 0xFFFF) << endl;
      result << (dut->cordic__DOT__u_cordic_iteration__DOT__cordic_data[i][num_iter_per_stage][1] & 0xFFFF) << endl;
      result << (dut->cordic__DOT__u_cordic_iteration__DOT__cordic_data[i][num_iter_per_stage][0] & 0xFFFF) << endl;
    }
    result << ((dut->o_data >> 32) & 0xFFFF) << endl;
    result << ((dut->o_data >> 16) & 0xFFFF) << endl;
    result << ((dut->o_data >>  0) & 0xFFFF) << endl;
    result.close();

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}
