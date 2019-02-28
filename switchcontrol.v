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


module switchcontrol #(parameter address=`TAM_FLIT)
    ( input clk,
      input reset,
      input  [`NPORT-1:0] h,
      output reg [`NPORT-1:0] ack_h,
      input [`TAM_FLIT-1:0] data,
      input [`NPORT-1:0] sender, 
      output  [`NPORT-1:0] free,
      output  [`reg3 -1:0] mux_in,
      output reg  [`reg3 -1:0] mux_out      
    );
    reg [$clog2(`STATE)-1:0] ES,PES;
    reg ask;
    reg [$clog2(`NPORT)-1:0] sel,prox;
    reg [`reg3-1:0] incoming;
    reg [`TAM_FLIT-1:0] header;
    reg  ready,enable;
    
    reg [$clog2(`NPORT)-1:0] indice_dir;
    reg [`NPORT-1:0] auxfree;
    reg [`reg3 -1:0] source;
    reg [`NPORT-1:0] sender_ant;
    reg [`NPORT-1:0] dir;
    wire [`NPORT-1:0] requests;
    
    reg [3:0] find;
    integer selectedOutput;
    reg isOutputSelected;
    integer i;

    always@(*)
    begin
     ask= (|h)? 1:0;
     incoming=sel;
     header=data[incoming];
     end
         RoundRobinArbiter rr1(.requests(h),.enable(enable),.selectedOutput(prox),.isOutputSelected(ready));
         routingMechanism rm1(.clock(clock),.reset(reset),.dest(header),.outputPort(dir),.find(find));
         FixedPriorityArbiter fp1(.requests(requests),.enable(1),.isOutputSelected(isOutputSelected),.selectedOutput(selectedOutput)); 
    always@(reset,clock)
        begin
            if (reset==1)
                begin
                 ES<=`S0;
                    if (/*event clock? and*/  clock==1)
                        begin
                         ES<=PES;   
                        end
                end
        end 
    always@(ES, ask, find, isOutputSelected) 
        begin
            case(ES)
                
                `S0: PES<=`S1;
                `S1: 
                    begin
                        if (ask==1)
                            begin
                                PES<=`S2;
                            end
                            
                       else
                            begin
                                PES<=`S1;                     
                            end
                     end
               `S2: PES<=`S3;
               `S3: 
                    begin
                        if (find==`validRegion)
                            begin
                                if(isOutputSelected==1)
                                    begin
                                        PES<=`S4;
                                    end
                                else
                                    begin
                                        PES<=`S1;                                    
                                    end
                              
                            end
                       if (find==`portError)
                           begin
                            PES<=`S1;
                           
                            end    
                       else 
                           begin
                           PES <= `S3;
                           end                        
                    end
               `S4: PES<=`S5;                       
               `S5: PES<=`S1;                                
            endcase 
        end
always@(posedge clock)
            begin
            case(ES)
                //zera variáveis
                `S0:begin
                    //ceTable<=0;
                    sel<=0;
                    ack_h<=0;
                    auxfree<=0;
                    sender_ant<=0;
                    mux_out<=0;
                    source<=0;
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
                    mux_out[indice_dir] <= incoming;
                    auxfree[indice_dir] <= 0;
                    ack_h[sel] <= 1;
                    end
                default:begin
                    ack_h[sel] <= 0;
                    //ceTable <= '0';
                    end        
            endcase
            sender_ant<=sender;
            for(i=`EAST;i<=`LOCAL;i=i+1)
                if (sender[i] == 0 & sender_ant[i] == 1)
                    auxfree[source[i]] <= 1;
            end
            assign mux_in=source;
            assign free=auxfree;
            assign requests=auxfree & dir;


    endmodule
