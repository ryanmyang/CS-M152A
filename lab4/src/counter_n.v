`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Configurable N-bit counter
//////////////////////////////////////////////////////////////////////////////////

module counter_n
    #(parameter BITS = 4)
(
    input clk,
    input rst,
    output tick,
    output [BITS - 1 : 0] q
);
    
    // counter register
    reg [BITS - 1 : 0] rCounter;
    
    // increment or reset the counter
    always @(posedge clk, posedge rst)
        if (rst)
            rCounter <= 0;
        else
            rCounter <= rCounter + 1;

    // connect counter register to the output wires
    assign q = rCounter;
    assign tick = (rCounter == 2 ** BITS - 1) ? 1'b1 : 1'b0;
        
endmodule
