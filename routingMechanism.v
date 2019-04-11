`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.02.2019 10:22:55
// Design Name: 
// Module Name: routingMechanism
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
module routingMechanism#(parameter adress=16)(
input clock,reset,
input [`TAM_FLIT-1:0]dest,
output reg [`NPORT-1:0]outputPort,
output [`ROUTERCONTROL-1:0]find
    );

    wire [`METADEFLIT-1:0] local_x;
    wire [`METADEFLIT-1:0] dest_x;
    wire [`METADEFLIT-1:0] local_y;
    wire [`METADEFLIT-1:0] dest_y;

    always@(*)
        begin
        outputPort=0;
        if (dest_x>local_x)
            outputPort[`EAST]=1;
        else
            if (dest_x<local_x)
                outputPort[`WEST]=1;
            else 
               if (dest_y<local_y)
                   outputPort[`SOUTH]=1;
               else
                   begin  
                   if (dest_y>local_y)
                       outputPort[`NORTH]=1;
                   else
                       outputPort[`LOCAL]=1; 
                   end           
        end
    assign local_x= adress[`TAM_FLIT-1:`METADEFLIT];
    assign local_y= adress[`METADEFLIT-1:0];
    assign dest_x=dest[`TAM_FLIT-1:`METADEFLIT];
    assign dest_y=dest[`METADEFLIT-1:0];
    assign find=`validRegion;   
endmodule
