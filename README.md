# Phoenix NoC- Verilog

This project is a implementation of the Phoenix NoC (originally designed in VHDL) using the Verilog HDL.

### Configuration

The files here configure a 3x3 NOC, to receive packages with 9 flits of 16 bits each.
    
To change the size of the NoC: rtl/defines.vh change NUM_X and NUM_Y to the number of routers you want in each axis. Then in tb/noc.h change the defines num_router and num_y;

To change the size of the flits in a package, in rtl/defines.vh change TAM_BUFFER so one package can fit in the buffer.

It is also necessary to configure the number of test packages: In tb/noc.h change num_pkg
   
The files in tests were generated by a java traffic-gen and are adapted to the current configuration of the NOC, if you want to test another configuration you need to generate new input files.
   

### Dependencies

    verilator

### Command line arguments

The main in /tb receive the files in /tests which are used as input packages to the router with matching address

### Defines
#### __VERILATOR
This define must be used to adapt the top file NOC.v to the simulation via Verilator

### Make commands

#### all
```
$make all
```
Compile necessary files using verilator to create an executable program.

#### tests
```
$make tests
```
Run all traffic input files in /tb

