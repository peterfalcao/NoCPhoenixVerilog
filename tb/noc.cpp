#include "noc.h"
#include <math.h>

NOC::NOC(){// Cria o Objeto e inicializa as variáveis necessárias
	this->dut =new VNOC;
	this->mtime=0;
	trace_f=NULL;
	flit_counter=new int[num_router];
	flit_counter_out=new int[num_router];
	pkg_counter= new int[num_router];
	pkg_counter_out= new int[num_router];
	has_pkg_aux= new bool[num_router];
	flit_array= new int[num_router];
	done= new int[num_router];
	this->aOut_numpkg= new int[num_router];
	this->arrayOut = new int**[num_router];
	this->array3D=new int**[num_router];
	this->rx=0;
	for(uint32_t i=0;i<num_router;i++){
		flit_counter[i]=0;//num_router
		pkg_counter[i]=0;
		pkg_counter_out[i]=0;
		flit_counter_out[i]=0;
		has_pkg_aux[i]=false;
		rt[i].id=i;
		flit_array[i]=0;
		done[i]=0;
	}
	status=0;
}

NOC::~NOC(){//Deleta o objeto e libera a memoria dos arrays criados
	if(trace_f) {
		trace_f->close();
		trace_f = NULL;
		}
	delete flit_counter;
	delete flit_counter_out;
	delete pkg_counter;
	delete pkg_counter_out;
	delete has_pkg_aux;
	delete array3D;
	delete arrayOut;
	delete aOut_numpkg;
	delete flit_array;
}

void NOC::tick() {
	this->mtime++;
	dut->clock = 0;
	this->sendpackage();
	dut->eval();
	if(trace_f) trace_f->dump(this->mtime);

	this->mtime++;
	dut->clock = 1;
	for(uint32_t i=0;i<num_router;i++){
		this->has_pkg(i);
	}
	dut->eval();
	if(trace_f) trace_f->dump(this->mtime);
}

void NOC::reset() {// Mtime comentado= reset nao eh mostrado no gtkwave
	for(uint32_t i = 0; i < 2; i++) {
		dut->clock = 0;
    	dut->reset = 1;
		//this->mtime++;
		dut->eval();
		if(trace_f) trace_f->dump(this->mtime);
		
		dut->clock = 1;
    	dut->reset = 1;
		//this->mtime++;
		dut->eval();
		if(trace_f) trace_f->dump(this->mtime);

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

int NOC::getStatus(){
	return this->status;
}

void NOC::initPkgChecker(){
	uint32_t i,j,k;
	for(i=0;i<num_router;i++){
		this->arrayOut[i] = new int*[this->aOut_numpkg[i]];
		for(j=0;j<this->aOut_numpkg[i];j++){
			this->arrayOut[i][j]=new int[num_flit];
			for(k=0;k<num_flit;k++){
				this->arrayOut[i][j][k]=0;
			}
		}
	}
}

void NOC::countPkgOut(int dest){
	int router;
	router=calculateRouter(dest);
	this->aOut_numpkg[router]++;
}

int NOC::calculateRouter(int address){
    int d;
	for(uint32_t i=0;i<num_router;i++){
		stringstream ss;
		ss<<hex<<this->rt[i].addr;
		ss>>d;
		if(d==address){
			return this->rt[i].id;
		}
	}
	return -1;
}

void NOC::initRouter(string address){
    stringstream sx,sy;
    int x,y;
    for(uint32_t i=0;i<num_router;i++){
    	sx<<hex<<address.substr(18,2);
    	sx>>x;
		if(i/num_y==x){
			sy<<hex<<address.substr(20,2);
    		sy>>y;
			if(i%num_y==y){
				this->rt[i].addr=address.substr(18,2)+address.substr(20,2);
				//cout<<"rt "<<i<<" = "<<this->rt[i].addr<<endl;
				break;
			}
		}
	}
}

void NOC::readtraffic(string address) {
    int i = 0;
    int j=0;
    int router;
    int addr;
    stringstream sx,sy;
    int x,y;
    sx<<hex<<address.substr(18,4);
    sx>>addr;
    router=calculateRouter(addr);
    this->array3D[router] = new int*[num_pkg];
    this->array3D[router][j] = new int[num_flit+1];//+1= tempo de envio
    for(uint32_t flit;flit<num_flit;flit++)
    	this->array3D[router][j][flit]=0;
    ifstream inFile;
    inFile.open(address);
    if (!inFile) {
        cout << "Unable to open file from router "<<router<<endl;
    }
    while (inFile>>hex>>this->array3D[router][j][i]) {//os flits são armazenados nas posições de pacote
        if(i==1){
        	countPkgOut(this->array3D[router][j][i]);
        }
        //para completar a quantidade de flits desejada
       /* if(i==2){
        	this->array3D[router][j][i]=this->array3D[router][j][i]+6;//16 flits/pkg
        }*/
        i++;
        if(i>num_flit){//se o pacote acabar, zerar o contador para o proximo pacote
	        i=0;
	        if(j<num_pkg-1){
	        	j++;
	            this->array3D[router][j] = new int[num_flit+1];
	            for(uint32_t flit;flit<num_flit;flit++)
    				this->array3D[router][j][flit]=0;      		
        	}
        	else
        		break;

        }
    }
    inFile.close();
} 

void NOC::sendpackage(){
	long int mask;
	for(uint32_t i=0;i<num_router;i++){
		this->sendflit(i);
	}
} 

void NOC::sendflit(int router){
	int flit=0;
	if(this->has_pkg(router)){
		//if(router==5 &&flit_counter[5]==0)
		//	cout<<"mtime: "<<this->mtime<<endl;
		if(this->flit_counter[router]<num_flit+1){//num_flit
			flit= this->getflit(router);
			this->insert_data(flit,router);
			this->flit_counter[router]++;
		}
		else{
			this->flit_counter[router]=0;
			this->has_pkg_aux[router]=false;
			if(this->pkg_counter[router]<num_pkg-1){
				this->pkg_counter[router]++;//ler a proxima linha do arquivo de entrada
			}
			disable_rx(router);
		}
	} 
}

bool NOC::has_pkg(int router){
	int pkg_in_time=this->array3D[router][this->pkg_counter[router]][0];//ver posiçao do tempo
	if(pkg_in_time==this->mtime){
		this->has_pkg_aux[router]=true;
	}
	return this->has_pkg_aux[router];
}

int NOC::getflit(int router){
	int flit=this->array3D[router][this->pkg_counter[router]][this->flit_counter[router]];
	return flit;
}


void NOC::insert_data(int flit, int router){
	int aux;
	this->flit_array[router]=flit;
	//ligar sinal rx
	if(this->flit_counter[router]>0){
		aux=pow(2,router);
		this->rx=this->rx|aux;
		dut->rxLocal=this->rx;
	}
}

int NOC::getdata (int i) {
	return this->flit_array[i]; 
}

void NOC::disable_rx(int router){
	int aux;
	aux=pow(2,router);
	aux=~aux;
	this->rx=this->rx&aux;
	dut->rxLocal=this->rx;
}


void NOC::fillDataOut(int flit, int router){
	//cout<<"entrou"<<endl;
	long int mask;
	int txaux;
	int sender;
	txaux=1<<router;
	mask=0xFFFF;	
	if(((dut->txLocal)&txaux)!=0){//fazer mascara com cada i
		
		this->arrayOut[router][this->pkg_counter_out[router]][this->flit_counter_out[router]]=flit;
		
		this->flit_counter_out[router]++;
	}

	if((this->pkg_counter_out[router]==this->aOut_numpkg[router]-1) && (flit_counter_out[router]>num_flit-1)){
			//cout<<"entrou1\n";
			//cout<<"entrou2\n";
			this->done[router]=1;
			uint32_t aux=0;
			for(uint32_t i=0;i<num_router;i++)
				if(this->done[i]==1)
					aux=aux+1;
			if(aux==num_router)
				this->status=1;

		}

	if(flit_counter_out[router]>num_flit-1){
		this->flit_counter_out[router]=0;
		if(this->pkg_counter_out[router]<this->aOut_numpkg[router]){
			/*if(router==6){
				cout<<"router "<<router<<" possui "<<this->pkg_counter_out[router]<<" pacotes\n";
				cout<<"n de pkg: "<<aOut_numpkg[router]<<endl;
				}*/
			this->pkg_counter_out[router]++;	
		}
	}


	//cout<<"terminou"<<endl;
}

void NOC::checkPkg(){
	int router;
	int failpkg;
	bool sucess;
	cout<<"*******************Checando a NOC*******************"<<endl;
	for(uint32_t i=0;i<num_router;i++){
		cout<<"-----------------Iniciando Checagem do Roteador "<<hex<<rt[i].addr<<" | "<< i <<"-----------------"<<endl;
		sucess =true;
		failpkg=0;
		for(uint32_t j=0;j<num_pkg;j++){
			int dest=this->array3D[i][j][1];
			router=calculateRouter(dest);
			int y=0;
			int x=0;
			//cout<<"j= "<<j<<endl;
			while(y<aOut_numpkg[router] && x<num_flit){
				//cout<<"vai pro if\n";
				if(this->array3D[i][j][x+1]!=this->arrayOut[router][y][x]){
					y++;
					x=0;
				}
				else{
					x++;
				}
			//	cout<<"y= "<<y<<endl;
			//	cout<<"aOut_numpkg= "<<aOut_numpkg[router]<<endl;
			}
			//cout<<"passou do while\n";
			if(x!=num_flit){
				sucess= false;
				failpkg++;
			//	cout<<"Pacote "<<dec<<j<<" do roteador "<<hex<<rt[i].addr<<" nao chegou no destino, o roteador: "<<hex<<rt[router].addr<<endl;
			}	
		}
		//cout<<"passou do for\n";
		if(sucess)
			cout<<"Todos os pacotes do roteador "<<hex<<rt[i].addr<<" chegaram ao destino com sucesso"<<endl;
		else
			cout<<dec<<failpkg<<" Pacote(s) do roteador "<<hex<<rt[i].addr<<" nao chegaram ao destino"<<endl;
	}
	
}


