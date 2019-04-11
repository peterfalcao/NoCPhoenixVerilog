`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 27.02.2019 17:16:16
// Design Name:
// Module Name: switchcontrol
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
module switchcontrol #(parameter address=`TAM_FLIT)
    ( input clock,
      input reset,
      input  [`NPORT-1:0] h,
      output reg [`NPORT-1:0] ack_h,
      input [`NP_REGF-1:0] data_in,
      input [`NPORT-1:0] sender,
      output  [`NPORT-1:0] free,
      output reg [`NP_REG3-1:0] mux_in,
      output reg  [`NP_REG3-1:0] mux_out
    );
    //output  [`reg3 -1:0] mux_in,
    //      output reg  [`reg3 -1:0] mux_out
    reg [`reg3-1:0]mux_in_a[`NPORT-1:0];
    reg [`reg3-1:0]mux_out_a[`NPORT-1:0];
    reg [`TAM_FLIT-1:0]data[`NPORT-1:0];// arrayNport_regflit
    reg [$clog2(`STATE)-1:0] ES,PES;
    reg ask=0;
    reg enable;
    reg [$clog2(`NPORT)-1:0] sel=0;
    reg [`reg3-1:0] incoming=0;
    reg [`TAM_FLIT-1:0] header=0;
    reg [$clog2(`NPORT)-1:0] indice_dir=0;
    reg [`NPORT-1:0] auxfree;
    reg [`reg3 -1:0] source [`NPORT-1:0];
    reg [`NPORT-1:0] sender_ant;
    wire [`NPORT-1:0] dir;
    wire [`NPORT-1:0] requests;
    wire [$clog2(`NPORT)-1:0] prox;
    wire [$clog2(`NPORT)-1:0]selectedOutput;
    wire [`ROUTERCONTROL-1:0] find;
    wire isOutputSelected, ready;
    integer i;

    RoundRobinArbiter rr1(.requests(h),.enable(enable),.selectedOutput(prox),.isOutputSelected(ready));
    routingMechanism #(address)rm1(.dest(header),.outputPort(dir),.find(find));
    FixedPriorityArbiter fp1(.requests(requests),.enable(1'b1),.isOutputSelected(isOutputSelected),.selectedOutput(selectedOutput));

    always@(*)
        begin
        for(i=0;i<`NPORT;i=i+1)
            mux_in_a[i]=source[i];
        if(`NPORT==5)
            begin
            {data[4],data[3],data[2],data[1],data[0]}=data_in;
            mux_in={mux_in_a[4],mux_in_a[3],mux_in_a[2],mux_in_a[1],mux_in_a[0]};
            mux_out={mux_out_a[4],mux_out_a[3],mux_out_a[2],mux_out_a[1],mux_out_a[0]};
            end
        ask =(|h)? 1:0;
        incoming=sel;
        header=data[incoming];


        end

    always@(ES, ask, find, isOutputSelected)
        begin
            case(ES)
                `S0: PES=`S1;
                `S1:
                    begin
                    if (ask==1)
                        begin
                        PES=`S2;
                        end
                    else
                        PES=`S1;
                     end
               `S2: PES=`S3;
               `S3:
                    begin
                    if (find==`validRegion)
                        begin
                        if(isOutputSelected==1)
                            PES=`S4;
                        else
                            PES=`S1;
                        end
                    else
                        if (find==`portError)
                            PES=`S1;
                        else
                            PES = `S3;
                    end
               `S4: PES=`S5;
               `S5: PES=`S1;
            endcase
        end
    always@(posedge clock)
        begin
        if (reset==1)
            ES<=`S0;
        else
            begin
            ES<=PES;
            case(ES)
                //zera vari�veis
                `S0:begin
                    //ceTable<=0;
                    sel<=0;
                    ack_h<=0;
                    sender_ant<=0;
                    for(i=0;i<`NPORT;i=i+1)
                        begin
                        auxfree[i]<=1;
                        mux_out_a[i]<=0;
                        source[i]<=0;
                        end
                    end
                //chega um header
                `S1:begin
                    enable<=ask;
                    //ceTable<=0;
                    ack_h<=0;
                    end
                // Seleciona quem tera direito a requisitar roteamento
                `S2:begin
                    sel <= prox;
                    enable <= ~ready;
                    end
                //Aguarda resposta da Tabela
                `S3:begin
                    if(find == `validRegion & isOutputSelected ==1)
                        indice_dir <= selectedOutput;
                    //else
                        //ceTable=1;
                    end
                `S4:begin
                    source[incoming] <= indice_dir;
                    mux_out_a[indice_dir] <= incoming;
                    auxfree[indice_dir] <= 0;
                    ack_h[sel] <= 1;
                    end
                default:begin
                    ack_h[sel] <= 0;
                    //ceTable <= '0';
                    end
            endcase

            for(i=`EAST;i<=`LOCAL;i=i+1)
                if (sender[i] == 0 & sender_ant[i] == 1)
                    begin
                    auxfree[source[i]] <= 1;
                    //auxfree[i] <= 1;
                    end

           end

        end
    always@(posedge clock) begin
        if(!reset) begin
            sender_ant <= sender;//_ant_2;
        end
    end

    //assign mux_in_a=source; realocado para o always combinacional
    assign free=auxfree;
    assign requests=auxfree & dir;



    endmodule
