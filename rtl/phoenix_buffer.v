`include "defines.vh"
module phoenix_buffer #(DEPTH=`TAM_BUFFER)(
input clock, reset,rx, clock_rx,ack_h,data_ack,
input [`TAM_FLIT-1:0] data_in,
output credit_o,h,data_av,sender,
output [`TAM_FLIT-1:0] data);


localparam REQ_ROUTING=0;
localparam SEND_DATA=1;

wire pull, has_data,has_data_and_sending;
wire [`TAM_FLIT-1:0] bufferhead;
wire [$clog2(DEPTH):0]counter;
reg [`TAM_FLIT-1:0] counter_flit;
reg sending,sent;
reg next_state, current_state;
integer flit_index;

fifo_buffer CBUF(
.reset(reset),
.clock(clock_rx),
.tail(data_in),
.push(rx),
.pull(pull),
.counter(counter),
.head(bufferhead)
);

always@(current_state or ack_h or sent)
begin
    next_state=current_state;
    case(current_state)
    REQ_ROUTING:
        if (ack_h)
            next_state=SEND_DATA;
    SEND_DATA:
        if (sent)
            next_state=REQ_ROUTING;       
    endcase
end

always@(posedge clock)
    begin
    if (reset)
        begin
        current_state<= REQ_ROUTING;
        sent<=0;
        end
    else
        begin
        current_state<= next_state;
        if(sending)
            begin
            if (data_ack & has_data)
                begin
                sent<=0;
                if (flit_index==1)
                    counter_flit<=bufferhead;
                else 
                    begin
                    if(counter_flit!=1)
                        counter_flit<=counter_flit-1;
                    else//se counter_flit=1
                        sent<=1;
                    end                           
                flit_index<=flit_index+1;
                end
            end
        else
            begin
            flit_index<=0;
            counter_flit<=0;
            sent<=0;
            end
        end
    end
    
always@(current_state or sent)
begin
    case (current_state)
        SEND_DATA:
            sending= !sent;
        default:
            sending=0;
    endcase
end

assign data= bufferhead;
assign data_av= has_data_and_sending;
assign credit_o=((counter!=DEPTH) | (pull==1))?1:0;
assign sender=sending;
assign h=has_data &(!sending);
assign pull= data_ack &has_data_and_sending;
assign has_data= (counter!=0)?1:0;
assign has_data_and_sending= has_data & sending;

endmodule