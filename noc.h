#pragma once

#include <iostream>
#include <iomanip>
#include <fstream>
#include <vector>
#include <string>
#include <stdint.h>
using namespace std;
#include "VNOC.h"
#include "verilated_vcd_c.h"


class NOC{
	VNOC* dut;
	VerilatedVcdC *trace_f;
	uint64_t mtime;
	std::string path;
public:
	NOC();
	~NOC();
	void tick();
	void reset();
	void open_trace(const char* path);
	int** readtraffic();
	void sendpackage(int* package);
};