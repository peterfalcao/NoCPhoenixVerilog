`include"defines.vh"

module NOC(
   input [`NROT-1:0]rxLocal,
   input reset,clock,
`ifndef __VERILATOR
   input [`NR_REGF-1:0]data_inLocal_flit,
   output [`NR_REGF-1:0]data_outLocal_flit,
`endif
   output [`NROT-1:0] credit_oLocal,clock_txLocal,txLocal
   );

`ifdef __VERILATOR
    import "DPI-C" function int getflit (input int router);
    import "DPI-C" function void saveData (input int flit, input int router);
    reg [`TAM_FLIT-1:0]data_inLocal_aux[`NROT-1:0];
`endif
/* verilator lint_off UNOPTFLAT */
    wire [`NP_REGF-1:0]data_in[`NROT-1:0];
    wire [`NPORT-1:0]rx[`NROT-1:0];
    wire [`NPORT-1:0] clock_rx[`NROT-1:0];
    wire [`NPORT-1:0] credit_i[`NROT-1:0];
    wire [`NPORT-1:0] credit_o[`NROT-1:0];
    wire [`NPORT-1:0] clock_tx[`NROT-1:0];
    wire [`NPORT-1:0] tx[`NROT-1:0];
    wire [`NP_REGF-1:0] data_out[`NROT-1:0]; 
    

    /* verilator lint_off WIDTH */
    function [`TAM_FLIT-1:0]addr;
      input [$clog2(`NROT)-1:0]index;
      reg [`METADEFLIT-1:0]addrX, addrY;
      begin
      addrX=index/`NUM_Y;
      addrY=index%`NUM_Y;
      addr={addrX,addrY};
      end
    endfunction
    /* verilator lint_on WIDTH */
    initial $display("nrot= %d",`NROT);
    genvar i;
    generate
    for(i=0; i<`NROT;i=i+1)
        begin
        routercc #(.address(addr(i)))router(
            .clock(clock),
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
        //initial $display("Router %d :EAST", i);
        assign clock_rx[i][0]=clock_tx[i+`NUM_Y][1];
        assign rx[i][0]=tx[i+`NUM_Y][1];
        assign data_in[i][`TAM_FLIT-1:0]=data_out[i+`NUM_Y][(`TAM_FLIT*2)-1:`TAM_FLIT];
        assign credit_i[i][0]= credit_o[i+`NUM_Y][1];
        end
    //WEST
    if(i>=`NUM_Y)
        begin
        //initial $display("Router %d :WEST", i);
        assign clock_rx[i][1]=clock_tx[i-`NUM_Y][0];
        assign rx[i][1]=tx[i-`NUM_Y][0];
        assign data_in[i][(`TAM_FLIT*2)-1:`TAM_FLIT]=data_out[i-`NUM_Y][`TAM_FLIT-1:0];
        assign credit_i[i][1]= credit_o[i-`NUM_Y][0];
        end
    //NORTH
    if(i-(i/`NUM_Y)*`NUM_Y<`MAX_Y)
        begin
        //initial $display("Router %d :NORTH", i);
        assign clock_rx[i][2]=clock_tx[i+1][3];
        assign rx[i][2]=tx[i+1][3];
        assign data_in[i][(`TAM_FLIT*3)-1:`TAM_FLIT*2]=data_out[i+1][(`TAM_FLIT*4)-1:`TAM_FLIT*3];
        assign credit_i[i][2]=credit_o[i+1][3];
        end
    //SOUTH
    if(i-(i/`NUM_Y)*`NUM_Y>`MIN_Y)
        begin
        //initial $display("Router %d :SOUTH", i);
        assign clock_rx[i][3]=clock_tx[i-1][2];
        assign rx[i][3]=tx[i-1][2];
        assign data_in[i][(`TAM_FLIT*4)-1:`TAM_FLIT*3]=data_out[i-1][(`TAM_FLIT*3)-1:`TAM_FLIT*2];
        assign credit_i[i][3]= credit_o[i-1][2];
        end
    //LOCAL
`ifdef __VERILATOR    
    always@(negedge clock)
        begin
            /* verilator lint_off WIDTH */
            data_inLocal_aux[i]<=getflit(i);
            /* verilator lint_on WIDTH */
        end
    always@(posedge clock)
        begin
          //  int j;
          //  for(j=0;j<`NROT-1;j=j+1)
          //  begin
                if (tx[i][`LOCAL]!=0) 
                    saveData({{16'b0},{data_out[i][(`TAM_FLIT*5)-1:`TAM_FLIT*4]}},i);
          //  end
       end
`endif
    assign clock_rx[i][`LOCAL]=clock;

`ifdef __VERILATOR
    assign data_in[i][(`TAM_FLIT*5)-1:`TAM_FLIT*4]=data_inLocal_aux[i];
`else
    assign data_in[i][(`TAM_FLIT*5)-1:`TAM_FLIT*4]=data_inLocal_flit[i*`TAM_FLIT+:`TAM_FLIT];
`endif    

    assign credit_i[i][`LOCAL]= tx[i][`LOCAL];
    assign rx[i][`LOCAL]=rxLocal[i];  
    assign clock_txLocal[i]=clock_tx[i][`LOCAL];

`ifndef __VERILATOR
    assign data_outLocal_flit[i*`TAM_FLIT+:`TAM_FLIT]=data_out[i][(`TAM_FLIT*5)-1:`TAM_FLIT*4];
`endif

    assign credit_oLocal[i]=credit_o[i][`LOCAL];
    assign txLocal[i]=tx[i][`LOCAL];
    end
endgenerate
/* verilator lint_on UNOPTFLAT */

endmodule
