SOURCES= $(wildcard *.v)
SOURCES+= defines.vh
#SOURCES-= topNOC.v
TOP= NOC
INFILES= $(wildcard *.txt)
all: $(SOURCES) main.cpp noc.cpp
	verilator -Wall --cc $(SOURCES) --top-module $(TOP) --trace --exe main.cpp noc.cpp -CFLAGS "-std=c++0x -Wall"
	make -j -C obj_dir -f VNOC.mk VNOC

run: all
	obj_dir/VNOC $(INFILES)

.PHONY: help clean

clean:
	rm -rf obj_dir
	rm -f *.vcd

help:
	echo $(SOURCES)


