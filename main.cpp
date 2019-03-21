#include <stdlib.h>
#include "verilated.h"
#include "VNOC.h"
#include "verilated_vcd_c.h"
#include <iostream>
#include <iomanip>
#include <fstream>
using namespace std;
#include "noc.h"

vluint64_t mtime = 0;


int main(int argc, char **argv) {
	// Initialize Verilators variables
	Verilated::commandArgs(argc, argv);
	Verilated::traceEverOn(true);
	// Create an instance of our module under test
	NOC* dut = new NOC;
	std::string path("wavefile");
	int **traffic=dut->readtraffic();
	int i=0;
	dut->open_trace((path+".vcd").c_str());
	dut->reset();
	dut->tick();	

	// Tick the clock until we are done
	while(mtime<50) {
		dut->tick();
		//verificar o flit correto e fazer um if para o tempo de envio
		dut->sendpackage(traffic[i]);
		dut ->tick();
		i++;
		mtime++;
	} 

	delete dut;
	return 0;
}


//criar a classe
//testar 1 pacote
//carregar o tráfego
//automatizar