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
integer i;
always@(posedge enable)
    begin 
    requestCheck=lastport;
//    $display("The value of 'requestCheck' out of loop is %d in %g",requestCheck,$time);
//    $display("The value of 'selectedPort' out of loop is %d in %g",selectedPort,$time);
//    $display("The value of 'lastPort' out of loop is %d in %g",lastport,$time);

    selectedPort=lastport;
    for (i = 0; i < size; i = i +1) 
        begin
        if(requestCheck==size-1)
            begin
            requestCheck=0;
 //            $display("The value of 'requestCheck' in if is %d in %g",requestCheck,$time);
            end
        else
            begin
            requestCheck=requestCheck+1;
//            $display("The value of 'requestCheck' in else is %d in %g",requestCheck,$time);
            end
            
        if(requests[requestCheck]==1)
            begin
            selectedPort=requestCheck;
            i=size;//simula o quit do vhdl
//             $display("The value of 'requestCheck' in if2 is %d in %g",requestCheck,$time);
            end
        end     
    lastport<=selectedPort;
    selectedOutput<=selectedPort;
    end
    
    assign isOutputSelected=enable;
endmodule
