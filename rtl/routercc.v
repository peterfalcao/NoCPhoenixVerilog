`include "defines.vh"
module routercc #(parameter address=`TAM_FLIT)(
    input clock,reset,
    input [`NPORT-1:0] credit_i, clock_rx, rx,
    input [`NP_REGF-1:0] data_in, 
    output [`NPORT-1:0] clock_tx, tx, 
    output [`NPORT-1:0] credit_o,
    output [`NP_REGF-1:0] data_out
    );
    genvar i;
    integer aux_var;
    wire [`NPORT-1:0]h, ack_h, data_av, sender, data_ack; 
    reg [`TAM_FLIT-1:0]data_inb[`NPORT-1:0];
    wire [`TAM_FLIT-1:0]data_outb[`NPORT-1:0];
    wire [`NPORT-1:0]free;   
    reg [`NP_REGF-1:0]data_in_t;
    wire [`NP_REG3-1:0]mux_in_t;
    wire [`NP_REG3-1:0]mux_out_t;

    generate
        for(i=`EAST; i<=`LOCAL;i=i+1)
            begin
            phoenix_buffer buffer(
            .clock(clock), 
            .reset(reset),
            .rx(rx[i]), 
            .clock_rx(clock_rx[i]),//nao usa clock_rx ainda
            .ack_h(ack_h[i]),
            .data_ack(data_ack[i]),
            .data_in(data_inb[i]),
            .credit_o(credit_o[i]),
            .h(h[i]),
            .data_av(data_av[i]),
            .sender(sender[i]),
            .data(data_outb[i]));
            end
    endgenerate
    
    switchcontrol #(.address(address)) swctrl
        (  .clock(clock),
           .reset(reset),
           .h(h),
           .ack_h(ack_h),
           .data_in(data_in_t),
           .sender(sender), 
           .free(free),
           .mux_in(mux_in_t),
           .mux_out(mux_out_t)
        );
        
    crossbar crossbar(
        .data_av(data_av),
        .free(free),
        .credit_i(credit_i),
        .data_in_t(data_in_t),
        .tab_in_t(mux_in_t), 
        .tab_out_t(mux_out_t),
        .data_ack(data_ack),
        .tx(tx), 
        .data_out_t(data_out));   
    
    always@(*)
        for (aux_var=0;aux_var<`NPORT;aux_var=aux_var+1)
            begin
            data_inb[aux_var]=data_in[aux_var*`TAM_FLIT+:`TAM_FLIT];
            data_in_t[aux_var*`TAM_FLIT+:`TAM_FLIT]=data_outb[aux_var];
            end

    generate
        for( i=0;i<=(`NPORT-1);i=i+1)
        begin
            assign clock_tx[i]=clock;
        end
    endgenerate 

endmodule
