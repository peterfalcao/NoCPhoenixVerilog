`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.02.2019 14:57:26
// Design Name: 
// Module Name: FixedPriorityArbiter
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
module FixedPriorityArbiter #(parameter size=`NPORT)
(
input [size-1:0] requests,
input enable,
output reg isOutputSelected,
output reg [$clog2(size)-1:0] selectedOutput 
 );
    
reg auxDone,exit_aux;
reg [$clog2(size)-1:0]auxSelect =0;
integer i;
    always@(requests,enable)
        begin
        auxDone=0;
        auxSelect =0;
        if(enable==1)
            begin  
            exit_aux=0;              
            for (i = 0; i < size; i = i +1) 
                begin
                if(requests[i]==1 & exit_aux==0)
                    begin
                    /* verilator lint_off WIDTH */
                    auxSelect=i;
                    /* verilator lint_on WIDTH */
                    auxDone=1;
                    exit_aux=1;
                    end
                end            
            end
        isOutputSelected= auxDone;
        selectedOutput= auxSelect;  
        end
     
endmodule
