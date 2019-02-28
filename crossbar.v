`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.02.2019 12:44:52
// Design Name: 
// Module Name: crossbar
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "defines.vh"
module crossbar (
input [`NPORT-1:0]data_av, sender, free, credit_i,
input [`NP_REGF-1:0] data_in_t,
input [`NP_REG3:0] tab_in_t , 
input [`NP_REG3:0] tab_out_t,
output [`NPORT-1:0] data_ack, tx, 
output reg[`NP_REGF-1:0] data_out_t );
    
    genvar i;
    reg [15:0]data_in[4:0];
    reg [2:0]tab_in[4:0];
    reg [2:0]tab_out[4:0];
    wire [15:0]data_out[4:0];
    
    always@(*)
        begin
        if(`NPORT==5)
            begin
            {data_in[4],data_in[3],data_in[2],data_in[1],data_in[0]}=data_in_t; 
            {tab_out[4],tab_out[3],tab_out[2],tab_out[1],tab_out[0]}=tab_out_t;
            {tab_in[4],tab_in[3],tab_in[2],tab_in[1],tab_in[0]}=tab_in_t;
            data_out_t={data_out[4],data_out[3],data_out[2],data_out[1],data_out[0]}; 
            end
        end
        
    generate
        for(i=`EAST; i<=`LOCAL;i=i+1)
            begin
            assign tx[i]= (free[i]==0)?data_av[tab_out[i]]:0;
            assign data_out[i]=(free[i]==0)?data_in[tab_out[i]]:0;
            assign data_ack[i]= (data_av[i]==1)?credit_i[tab_in[i]]:0;
            end
    endgenerate
endmodule
/*
module crossbar #(parameter NPORT=5, parameter TAM_FLIT=16)(
input [NPORT-1:0]data_av, sender, free, credit_i,
input [TAM_FLIT-1:0] data_in [NPORT-1:0],
input [2:0] tab_in [NPORT-1:0], 
input [2:0] tab_out [NPORT-1:0],
output [NPORT-1:0] data_ack, tx, 
output [TAM_FLIT-1:0] data_out [NPORT-1:0]);
    
    localparam EAST=0;
    localparam LOCAL=4;
    genvar i;
    generate
        for(i=EAST; i<=LOCAL;i=i+1)
            begin
            assign tx[i]= (free[i]==0)?data_av[tab_out[i]]:0;
            assign data_out[i]=(free[i]==0)?data_in[tab_out[i]]:0;
            assign data_ack[i]= (data_av[i]==1)?credit_i[tab_in[i]]:0;
            end
    endgenerate
endmodule*/
/*
regflit is std_logic_vector((TAM_FLIT-1) downto 0);
regNport is std_logic_vector((NPORT-1) downto 0);tamanho do barramento         
arrayNport_regflit is array((NPORT-1) downto 0) of regflit;       
arrayNport_reg3 is array((NPORT-1) downto 0) of reg3; 
reg3 is std_logic_vector(2 downto 0); 

       

*/