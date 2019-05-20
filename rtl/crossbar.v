`include "defines.vh"
module crossbar (
input [`NPORT-1:0]data_av, free, credit_i,
input [`NP_REGF-1:0] data_in_t,
input [`NP_REG3-1:0] tab_in_t , 
input [`NP_REG3-1:0] tab_out_t,
output [`NPORT-1:0] data_ack, tx, 
output reg[`NP_REGF-1:0] data_out_t );
    
    genvar i;
    integer aux_var;
    reg [`TAM_FLIT-1:0]data_in[`NPORT-1:0];
    reg [`reg3-1:0]tab_in[`NPORT-1:0];
    reg [`reg3-1:0]tab_out[`NPORT-1:0];
    wire [`TAM_FLIT-1:0]data_out[`NPORT-1:0];
    
    always@(*)
        begin
        for(aux_var=0;aux_var<`NPORT;aux_var=aux_var+1)
            begin
            data_in[aux_var]=data_in_t[aux_var*`TAM_FLIT+:`TAM_FLIT]; 
            tab_out[aux_var]=tab_out_t[aux_var*`reg3+:`reg3];
            tab_in[aux_var]=tab_in_t[aux_var*`reg3+:`reg3];
            data_out_t[aux_var*`TAM_FLIT+:`TAM_FLIT]=data_out[aux_var]; 
            end
        end
        
    generate
        for(i=`EAST; i<=`LOCAL;i=i+1)
            begin
            assign tx[i]= (free[i]==0)?data_av[tab_out[i]]:0;
            assign data_out[i]=(free[i]==0)?data_in[tab_out[i]]:0;
            assign data_ack[i]= (data_av[i]==1)?credit_i[tab_in[i]]:0;
            end
    endgenerate
endmodule
