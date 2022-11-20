#include <stdlib.h>
#include <iostream>
#include <iomanip>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vcordic.h"
#include "testcases.h"

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

void simple(int i){

    // Feed the i_data
    dut->i_vld = 1;
    dut->i_data = compose_i_data(func[i], x[i], y[i], z[i]);
    toggle();
    dut->i_vld = 0;
    toggle();
    
    // Wait for o_vld to become 1
    while(dut->o_vld != 1)
      toggle();

}

int main(int argc, char** argv, char** env) {
    dut = new Vcordic;
    Verilated::traceEverOn(true);
    m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    // Initialize DUT
    initialize_signals();

    // Run some simple cases
    for(int i=0;i<3;i++){
      std::cout << "Running testcase " << i << " ... ";
      simple(i);
      std::cout << "(i_data, o_data) = (" << std::hex << std::setw(13) << std::setfill('0') << dut->i_data << ", " << std::hex << std::setw(13) << std::setfill('0') << dut->o_data << ")" << std::endl;
    }

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}
