#include <stdlib.h>
#include "verilated.h"
#include "VNOC.h"
#include "verilated_vcd_c.h"
#include <iostream>
#include <iomanip>
#include <fstream>
using namespace std;
#include "noc.h"
#include "svdpi.h"
#include "VNOC__Dpi.h"

vluint64_t mtime = 0;
int gbltest =0;
NOC* dut;
int getflit (int router) { 
	return dut->getdata(router); 
}

void saveData(int flit, int router){
	dut->fillDataOut(flit, router);
}

int main(int argc, char **argv) {//verarv
	// Initialize Verilators variables
	Verilated::commandArgs(argc, argv);
	Verilated::traceEverOn(true);
	int suc_op=0;
	// Create an instance of our module under test
	dut = new NOC;
	std::string path("wavefile");
	cout<<"inicializou o codigo\n";
	for(uint32_t i=1;i<argc;i++){
		dut->initRouter(argv[i]);
	}
	cout<<"inicializou os routers\n";
	for(uint32_t i=1; i<argc;i++){
		//cout<<"argv: "<<argv[i]<<endl;
		dut->readtraffic(argv[i]);//argv1

	}
	dut->initPkgChecker();
	dut->open_trace((path+".vcd").c_str());
	dut->reset();
	cout<<"Noc Resetada"<<endl;
	dut->tick();	
	// Tick the clock until we are done
	while(mtime<8050 && !dut->getStatus()) {
		dut->tick();
		//verificar o flit correto e fazer um if para o tempo de envio
		mtime++;
	} 
	cout<<"terminou execução com mtime: "<<mtime<<endl;
	cout<<"status= "<<dut->getStatus()<<endl;
	suc_op=dut->checkPkg();
	delete dut;
	return suc_op;//RETORNAR O CHECKPKG
}
