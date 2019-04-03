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


int main(int argc, char **argv) {//verarv
	// Initialize Verilators variables
	Verilated::commandArgs(argc, argv);
	Verilated::traceEverOn(true);
	// Create an instance of our module under test
	NOC* dut = new NOC;
	std::string path("wavefile");
	for(uint32_t i=1;i<argc;i++){
		dut->initRouter(argv[i]);
	}
	for(uint32_t i=1; i<argc;i++){
		cout<<"argv: "<<argv[i]<<endl;
		dut->readtraffic(argv[i]);//argv1

	}
	dut->initPkgChecker();
	dut->open_trace((path+".vcd").c_str());
	dut->reset();
	cout<<"Noc Resetada"<<endl;
	dut->tick();	
	// Tick the clock until we are done
	while(mtime<30000) {
		dut->tick();
		//verificar o flit correto e fazer um if para o tempo de envio
		mtime++;
	} 
	cout<<"terminou execução"<<endl;
	dut->checkPkg();
	delete dut;
	return 0;
}