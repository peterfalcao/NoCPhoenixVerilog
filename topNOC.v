`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.03.2019 15:45:31
// Design Name: 
// Module Name: topNOC
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
module topNOC;

reg reset;
reg [`NPORT-1:0]clock,clock_rx,rx,credit_i;  
reg [`NP_REGF-1:0]data_in; 
reg [`TAM_FLIT-1:0]data[`NPORT-1:0];
wire [`NPORT-1:0]credit_o_r0,credit_o;
wire [`NPORT-1:0]clock_tx_r0,clock_tx;
wire [`NPORT-1:0]tx_r0,tx;
wire [`NP_REGF-1:0] data_out_r0,data_out_r1; 
reg [`TAM_FLIT-1:0]data_out_a[`NPORT-1:0];
routercc #(.address('h0000))r0(
  .clock(clock),
  .reset(reset),
  .credit_i(credit_i),
  .clock_rx(clock_rx),
  .rx(rx),
  .data_in(data_in),
  .credit_o(credit_o_r0), 
  .clock_tx(clock_tx_r0), 
  .tx(tx_r0),
  .data_out(data_out_r1)
  );
routercc #(.address('h0001))r1(
      .clock(clock),
      .reset(reset),
      .credit_i(credit_o_r0),
      .clock_rx(clock_tx_r0),
      .rx(tx_r0),
      .data_in(data_out_r1),
      .credit_o(credit_o), 
      .clock_tx(clock_tx), 
      .tx(tx),
      .data_out(data_out_r1)
      );   
      
    always@(*)
        begin
        data_in={data[4],data[3],data[2],data[1],data[0]};
        {data_out_a[4],data_out_a[3],data_out_a[2],data_out_a[1],data_out_a[0]}=data_out_r1;
        end
        
    always begin
        #10 clock=~clock;
        clock_rx[1]=~clock_rx[1];          
    end
    initial begin
    reset<=1;
    clock=0;
    clock_rx[1]=0;
    rx[1]=0;
    data[1]<=0;
    credit_i[1]<=1;
    credit_i[0]<=1;
    #10
    reset<=0;
    data[1]<='h0100;//inserir endereço de destino;
    #2
    rx[1]<=1;//começa transmissão
    #20
    data[1]<='h000d;
    #60
    data[1]<='h05ab;
    #35
    data[1]<='hf00f;
    #195
    rx[1]<=0;//encerra 300 t depois do inicio
    end
endmodule