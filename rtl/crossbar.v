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
input [`NPORT-1:0]data_av, free, credit_i,
input [`NP_REGF-1:0] data_in_t,
input [`NP_REG3-1:0] tab_in_t , 
input [`NP_REG3-1:0] tab_out_t,
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
