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


module RoundRobinArbiter #(parameter size=8)
(
input [size-1:0] requests,
input enable,
output isOutputSelected,
output reg [$clog2(size)-1:0] selectedOutput 
 );

reg [$clog2(size)-1:0] lastport;
reg [$clog2(size)-1:0] selectedPort =0;
reg [$clog2(size)-1:0] requestCheck;
reg i;
always@(posedge enable)
begin 
        requestCheck=lastport;
        selectedPort=lastport;
            for (i = 0; i < requests; i = i +1) 
                        begin
                            if(requestCheck==size-1)
                                begin
                                    requestCheck=0;
                                end
                            else
                                begin
                                    requestCheck=requestCheck+1;
                                end
                            if(requests[requestCheck]==1)
                                begin
                                    selectedPort=requestCheck;
                                end
                        end     
            
            lastport<=selectedPort;
            selectedOutput=selectedPort;

end
            assign isOutputSelected=enable;
endmodule
