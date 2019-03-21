SOURCES= $(wildcard *.v) 
SOURCES+= defines.vh
TOP= NOC
all: $(SOURCES) main.cpp
	verilator -Wall --cc $(SOURCES) --top-module $(TOP) --trace --exe main.cpp 
	make -j -C obj_dir -f VNOC.mk VNOC

run: all
	obj_dir/VNOC

.PHONY: help

clean:
	rm -rf obj_dir
	rm -f *.vcd

help:
	echo $(SOURCES)


