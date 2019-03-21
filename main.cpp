#include <stdlib.h>
#include "verilated.h"
#include "VNOC.h"
#include "verilated_vcd_c.h"
#include <iostream>
#include <iomanip>
#include <fstream>
using namespace std;

vluint64_t mtime = 0;


int* readpackage() {
    int i = 0;
    int *pacote[10];//10=tam_pacote
    ifstream inFile;
    //stringstream ss;  
    inFile.open("teste.txt");
    if (!inFile) {
        cout << "Unable to open file";
        return(1); // terminate with error
    }
    while (inFile>> std::hex>>pacote[i]) {//os flits são armazenados nas posições de pacote
      	cout <<"pacote "<<i<< " = "<< pacote[i]<<endl;
      	i++;
      	if(i>9){//se o pacote acabar, zerar o contador para o proximo pacote
      		i=0;
      	}
    }
    cout<<i;
    inFile.close();
    return pacote;
}        
int main(int argc, char **argv) {
	// Initialize Verilators variables
	Verilated::commandArgs(argc, argv);
	Verilated::traceEverOn(true);
	// Create an instance of our module under test
	VNOC *tb = new VNOC;
	VerilatedVcdC *m_trace= new VerilatedVcdC;

	int *pacote[10];

	tb->trace(m_trace, 99);
	m_trace->open("testwave.vcd");
	tb ->reset=0;
	tb->credit_iLocal=tb->txLocal;
	tb->eval();	
	m_trace->dump(mtime);
	mtime++;
	mtime++;
	//reset
	pacote=readpackage();
	printf("pacote[0]= %d",pacote[0]);
	tb->reset=1;
	for(int i=0;i<3;i++)
	{
		mtime++;		
		tb->clock = 0;
		tb->eval();
		mtime++;
		m_trace->dump(mtime);
		tb->clock = 1;
		tb->eval();
		mtime++;
		m_trace->dump(mtime);
		tb->clock = 0;
		tb->eval();
		mtime++;
		m_trace->dump(mtime);
		//m_trace->flush();
	}
	tb->reset=0;
	mtime++;
	mtime++;
	tb->eval();
	m_trace->dump(mtime);
	//if (m_trace) {
	//	}

	// Tick the clock until we are done
	int i=0;
	while(mtime<50) {
		tb->clock = 1;
		tb->eval();
		mtime++;
		m_trace->dump(mtime);
		tb->clock = 0;
		tb->data_inLocal_flit=pacote[i];
		if (i<10)
			{i++;}
		tb->eval();
		mtime++;
		m_trace->dump(mtime);
	} 
	m_trace->close();
	m_trace = NULL;
	exit(EXIT_SUCCESS);
}

//testar o reset
//fazer o dump
//ver as ondas
//criar a classe
//carregar o tráfego
//regra de clean
//automatizar