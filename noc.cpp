#include "noc.h"

NOC::NOC(){
	this->dut =new VNOC;
	mtime=0;
	trace_f=NULL;
}

NOC::~NOC(){
	if(trace_f) {
		trace_f->close();
		trace_f = NULL;
		}
}

void NOC::tick() {
	this->mtime++;
	dut->clock = 0;
	dut->eval();
	if(trace_f) trace_f->dump(mtime);

	this->mtime++;
	dut->clock = 1;
	dut->eval();
	if(trace_f) trace_f->dump(mtime);
}

void NOC::reset() {
	for(uint32_t i = 0; i < 2; i++) {
		dut->clock = 0;
    	dut->reset = 1;
		mtime++;
		dut->eval();
		if(trace_f) trace_f->dump(mtime);
		
		dut->clock = 1;
    	dut->reset = 1;
		mtime++;
		dut->eval();
		if(trace_f) trace_f->dump(mtime);

    	dut->reset = 0;
	}
}

void NOC::open_trace(const char* path) {
	if (!trace_f) {
		trace_f = new VerilatedVcdC;
		dut->trace(trace_f, 99);
		trace_f->open(path);
	}

}
int** NOC::readtraffic() {
    int i = 0;
    int j=0;
    int** array2D = 0;
    array2D = new int*[2];//trocar por numero de pacotes
    array2D[j] = new int[10];
    ifstream inFile;
    //stringstream ss;  
    inFile.open("teste.txt");
    if (!inFile) {
        cout << "Unable to open file";
        return array2D; // terminate with error
    }
    while (inFile>> std::hex>>array2D[j][i]) {//os flits são armazenados nas posições de pacote
        cout <<"array2d "<<j<<"/ "<<i<< " = "<< array2D[j][i]<<endl;
        i++;
        if(i>9){//se o pacote acabar, zerar o contador para o proximo pacote
          i=0;
          j++;
          array2D[j] = new int[10];
        }
    }
    cout<<i;
    inFile.close();
    return array2D;
} 

void NOC::sendpackage(int *package){
	for(uint32_t i=0;i<10;i++){
		dut->data_inLocal_flit=package[i];
		this->tick();
	}

} 