`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.02.2019 14:58:09
// Design Name: 
// Module Name: RoundRobinArbiter
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

`include"defines.vh"
module RoundRobinArbiter #(parameter size=`NPORT)
(
input [size-1:0] requests,
input enable,
output isOutputSelected,
output reg [$clog2(size)-1:0] selectedOutput 
 );

reg [$clog2(size)-1:0] lastport=0;
reg [$clog2(size)-1:0] selectedPort=0 ;
reg [$clog2(size)-1:0] requestCheck;
reg exit_aux;
integer i;
always@(posedge enable)
    begin 
    requestCheck=lastport;
    selectedPort=lastport;
    exit_aux=1;
    for (i = 0; i < size; i = i +1) 
        begin
        if(exit_aux==1)
        begin
        if(requestCheck==size-1 )//& exit_aux==1)
            begin
            requestCheck=0;
            end
        else
            //if(exit_aux==1)
                requestCheck=requestCheck+1;
            
        if(requests[requestCheck]==1 )//& exit_aux==1)
            begin
            selectedPort=requestCheck;
            exit_aux=0;//simula o quit do vhdl
            end
        end
        end     
    lastport<=selectedPort;
    selectedOutput<=selectedPort;
    end
    
    assign isOutputSelected=enable;
endmodule
