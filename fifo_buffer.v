<<<<<<< HEAD
module fifo_buffer #(parameter WIDTH=8, DEPTH=8)(
input clock, reset,push,pull,
input [WIDTH-1:0]tail,
output [WIDTH-1:0] head,
output [$clog2(DEPTH):0]counter
=======
`include "defines.vh"
module fifo_buffer #(parameter WIDTH=`TAM_FLIT, DEPTH=`TAM_BUFFER)(
input clock, reset,push,pull,
input [WIDTH-1:0]tail,
output [WIDTH-1:0] head,
output reg [$clog2(DEPTH):0]counter
>>>>>>> 8ce332d5fbf9f4a5d07eddc73b19c85eba6a0a35
);
reg [WIDTH-1:0] buff [DEPTH-1:0];
reg [$clog2(DEPTH)-1:0] first;
reg [$clog2(DEPTH)-1:0] last ;
reg [$clog2(DEPTH)-1:0] aux_first;
reg [$clog2(DEPTH)-1:0] aux_last ;
reg is_full,aux_is_full,is_empty;

<<<<<<< HEAD
always@(posedge clock)
begin
if(reset)
    begin
    last=0;
    first=0;
    is_full=0;
    is_empty=1;
    end
else
=======
always@(reset)
    begin
    if(reset)
        begin
        last=0;
        first=0;
        is_full=0;
        is_empty=1;
        counter=0;
        end
    end
always@(posedge clock)
begin
if(!reset)
>>>>>>> 8ce332d5fbf9f4a5d07eddc73b19c85eba6a0a35
    begin
    aux_is_full=is_full;
    aux_last=last;
    aux_first=first;
    if((!is_empty)&pull)
        begin
        aux_first=(aux_first== DEPTH-1)?0:(aux_first+1);
        aux_is_full=0;
        is_empty=(aux_first==aux_last)?1:0;
        end
    if((!aux_is_full)&push)
        begin
        buff[aux_last]<=tail;
        aux_last=(aux_last== DEPTH-1)?0:(aux_last+1);
        is_empty=0;
        aux_is_full=(aux_first==aux_last)?1:0;
        end
    is_full<=aux_is_full;
    last<=aux_last;
    first<=aux_first;
    end      
end

<<<<<<< HEAD
assign head=buff[first];
assign counter=is_full?DEPTH:(last>=first?(last-first):(DEPTH-(first-last)));
=======
always@(*)
    counter=is_full?DEPTH:(last>=first?(last-first):(DEPTH-(first-last)));

assign head=buff[first];
>>>>>>> 8ce332d5fbf9f4a5d07eddc73b19c85eba6a0a35

endmodule