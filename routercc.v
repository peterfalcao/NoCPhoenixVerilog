`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.02.2019 15:43:24
// Design Name: 
// Module Name: routercc
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
module routercc #(parameter address=`TAM_FLIT)(
    input clock,reset,
    input [`NPORT-1:0] credit_i, clock_rx, rx,//regNport
    input [`NP_REGF-1:0] data_in, //arraynportregflit
    output [`NPORT-1:0] credit_o, clock_tx, tx,//regNport 
    output [`NP_REGF-1:0] data_out//arraynportregflit
    );
    genvar i;
    integer j;
    reg [`NPORT-1:0]h, ack_h, data_av, sender, data_ack; //regNport
    wire [`NPORT-1:0]data[`TAM_FLIT-1:0];// arrayNport_regflit
    wire [`NPORT-1:0]free;//regNport
    
    reg [`NP_REGF:0]data_in_t;
    wire [`NP_REG3:0]mux_in_t;
    wire [`NP_REG3:0]mux_out_t;
    wire [`NP_REGF:0] data_out_t;
    generate
        for(i=`EAST; i<=`LOCAL;i=i+1)
            begin
            phoenix_buffer buffer(
            .clock(clock), 
            .reset(reset),
            .rx(rx[i]), 
            .clock_rx(clock[i]),//nao usa clock_rx ainda
            .ack_h(ack_h[i]),
            .data_ack(data_ack[i]),
            .data_in(data[i]),//regflict
            .credit_o(credit_o[i]),
            .h(h[i]),
            .data_av(data_av[i]),
            .sender(sender[i]),
            .data(data[i]));
            end
    endgenerate
    
    switchcontrol #(.address(address)) swctrl
        (  .clock(clock),
           .reset(reset),
           .h(h),
           .ack_h(ack_h),
           .data(data_in_t),
           .sender(sender), 
           .free(free),
           .mux_in(mux_in_t),
           .mux_out(mux_out_t)
        );
        
    crossbar crossbar(
        .data_av(data_av),
        .sender(sender),
        .free(free),
        .credit_i(credit_i),
        .data_in_t(data_in_t),
        .tab_in_t(mux_in_t), 
        .tab_out_t(mux_out_t),
        .data_ack(data_ack),
        .tx(tx), 
        .data_out_t(data_out));   
    

    always@(*)
        if(`NPORT==5)
            data_in_t={data_in[4],data_in[3],data_in[2],data_in[1],data_in[0]};
        
    generate
        for( i=0;i<=(`NPORT-1);i=i+1)
        begin
            assign clock_tx[i]=clock;
        end
    endgenerate    
endmodule
