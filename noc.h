#pragma once

#include <iostream>
#include <iomanip>
#include <fstream>
#include <sstream>
#include <vector>
#include <string>
#include <stdint.h>
using namespace std;
#include "VNOC.h"
#include "verilated_vcd_c.h"

#define num_pkg 24
#define num_flit 9
#define num_router 4
#define num_y 2 //altura da NOC
class NOC{
	VNOC* dut;
	VerilatedVcdC *trace_f;
	uint64_t mtime;
	std::string path;
	int* flit_counter;
	int* flit_counter_out;
	int* pkg_counter;
	int* pkg_counter_out;
	bool* has_pkg_aux;
	int*** array3D;
	int*** arrayOut;
	int* aOut_numpkg;
	long int data;
	int rx;
	struct rtr{
	string addr;
	int id;
	}rt[4];
public:
	NOC();
	~NOC();
	void tick();
	void reset();
	void open_trace(const char* path);
	void readtraffic(string address);
	void checkPkg();
	void initRouter(string address);
	void initPkgChecker();
private:
	void sendpackage();
	void sendflit(int router);
	int getflit(int router);
	bool has_pkg(int router);
	void insert_data(int flit, int router);
	void disable_rx(int router);
	void fillDataOut();
	int calculateRouter(int address);
	void countPkgOut(int dest);
};