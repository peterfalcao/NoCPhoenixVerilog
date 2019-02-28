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


module FixedPriorityArbiter #(parameter size=8)
(
input [size-1:0] requests,
input enable,
output reg isOutputSelected,
output reg [$clog2(size)-1:0] selectedOutput 
 );
 
   
reg auxDone;
reg [$clog2(size)-1:0]auxSelect =0;
reg i;
    always@(requests,enable)
    begin
    auxDone=0;
        if(enable==1)
            begin                
                for (i = 0; i < requests; i = i +1) 
                begin
                    if(requests[i]==1)
                        begin
                            auxSelect<=i;
                            auxDone<=1;
                        end
                end            
            end
    isOutputSelected=auxDone;
    selectedOutput= auxSelect;  
    end
     
endmodule
