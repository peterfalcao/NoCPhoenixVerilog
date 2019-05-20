SOURCES= $(wildcard rtl/*.v)
SOURCES+= rtl/defines.vh
#SOURCES-= topNOC.v
TOP= NOC
INFILES= $(wildcard ./tests/F007/In/*.txt)

all: $(SOURCES) tb/main.cpp tb/noc.cpp
	verilator -Wall --cc $(SOURCES) --top-module $(TOP) --trace -I./rtl --exe  tb/main.cpp tb/noc.cpp -CFLAGS "-std=c++0x -Wall"
	make -j -C obj_dir -f VNOC.mk VNOC

run: all
	obj_dir/VNOC $(INFILES)

tests: all
	python3 traffic_test.py

.PHONY: help clean test

clean:
	rm -rf obj_dir
	rm -f *.vcd

help:
	echo $(SOURCES)


