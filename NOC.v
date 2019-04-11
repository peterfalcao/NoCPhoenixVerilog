`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2019 15:07:11
// Design Name: 
// Module Name: NOC
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
module NOC(
   input [`NROT-1:0]clock,clock_rxLocal,rxLocal,credit_iLocal,
   input reset,
   input [`NR_REGF-1:0]data_inLocal_flit,
   output [`NROT-1:0] credit_oLocal,clock_txLocal,txLocal,
   output [`NR_REGF-1:0]data_outLocal_flit
   );
   
    wire [`NP_REGF-1:0]data_in[`NROT-1:0];
    wire [`NPORT-1:0]rx[`NROT-1:0];
    wire [`NPORT-1:0] clock_rx[`NROT-1:0];
    wire [`NPORT-1:0] credit_i[`NROT-1:0];
    wire [`NPORT-1:0] credit_o[`NROT-1:0];
    wire [`NPORT-1:0] clock_tx[`NROT-1:0];
    wire [`NPORT-1:0] tx[`NROT-1:0];
    wire [`NP_REGF-1:0] data_out[`NROT-1:0]; 
    
    genvar i;
    generate
    for(i=0; i<`NROT;i=i+1)
        begin
        routercc #(.address(i))router(
            .clock(clock[i]),
            .reset(reset),
            .credit_i(credit_i[i]),
            .clock_rx(clock_rx[i]),
            .rx(rx[i]),
            .data_in(data_in[i]),
            .credit_o(credit_o[i]), 
            .clock_tx(clock_tx[i]), 
            .tx(tx[i]),
            .data_out(data_out[i])
            );
        end
    endgenerate
 //INSERINDO VALORES NAS PORTAS
 generate
    for(i=0;i<`NROT;i=i+1)
    begin
    //EAST
    if(i<`NUM_Y*`MAX_X)
        begin
        assign clock_rx[i][0]=clock_tx[i+`NUM_Y][1];
        assign rx[i][0]=tx[i+`NUM_Y][1];
        assign data_in[i][`TAM_FLIT-1:0]=data_out[i+`NUM_Y][(`TAM_FLIT*2)-1:`TAM_FLIT];
        assign credit_i[i][0]= credit_o[i+`NUM_Y][1];
        end
    //WEST
    if(i>=`NUM_Y)
        begin
        assign clock_rx[i][1]=clock_tx[i-`NUM_Y][0];
        assign rx[i][1]=tx[i-`NUM_Y][0];
        assign data_in[i][(`TAM_FLIT*2)-1:`TAM_FLIT]=data_out[i-`NUM_Y][`TAM_FLIT-1:0];
        assign credit_i[i][1]= credit_o[i-`NUM_Y][0];
        end
    //NORTH
    if((i-(i/`NUM_Y))*`NUM_Y<`MAX_Y)
        begin
        assign clock_rx[i][2]=clock_tx[i+1][3];
        assign rx[i][2]=tx[i+1][3];
        assign data_in[i][(`TAM_FLIT*3)-1:`TAM_FLIT*2]=data_out[i+1][(`TAM_FLIT*4)-1:`TAM_FLIT*3];
        assign credit_i[i][2]= credit_o[i+1][3];
        end
    //SOUTH
    if((i-(i/`NUM_Y))*`NUM_Y>`MIN_Y)
        begin
        assign clock_rx[i][3]=clock_tx[i-1][2];
        assign rx[i][3]=tx[i-1][2];
        assign data_in[i][(`TAM_FLIT*4)-1:`TAM_FLIT*3]=data_out[i-1][(`TAM_FLIT*3)-1:`TAM_FLIT*2];
        assign credit_i[i][3]= credit_o[i-1][2];
        end
    //LOCAL
    assign clock_rx[i][`LOCAL]=clock_rxLocal[i];
    assign data_in[i][(`TAM_FLIT*5)-1:`TAM_FLIT*4]=data_inLocal_flit[i];
    assign credit_i[i][`LOCAL]= credit_iLocal[i];
    assign rx[i][`LOCAL]=rxLocal[i];
    
    assign clock_txLocal[i]=clock_tx[i][`LOCAL];
    assign data_outLocal_flit=data_out[i][(`TAM_FLIT*5)-1:`TAM_FLIT*4];
    assign credit_oLocal[i]=credit_o[i][`LOCAL];
    assign txLocal[i]=tx[i][`LOCAL];
    end
endgenerate

endmodule

