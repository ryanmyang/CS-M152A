`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/06/2025 01:47:13 PM
// Design Name: 
// Module Name: display_mux
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


module display_mux(
    input wire clk_500hz,
    input [3:0] dig3,
    input [3:0] dig2,
    input [3:0] dig1,
    input [3:0] dig0,
    input wire adj_sw,
    input wire sel_sw,
    input wire clk_4hz,
    output reg [3:0]an,
    output reg [6:0] seg
    );
    
    reg [1:0] sel = 0; //active one
    reg [3:0] num; // current digit to display 
    reg blink = 0; // blinking flag
    always @(posedge clk_4hz) begin
        blink <= ~blink; // toggle blink every 4hz
    end
    wire [6:0] seg_data; // segment data for the current digit
    reg blank_this_digit; //flag to toggle when need to blank out digit on flash
    num_to_7seg decoder(.num(num), .seg(seg_data));
    always @(posedge clk_500hz) begin
        // basically every cycle, increment which digit is active
        // when each digit is active, set the anode to 0 and the rest to 1
        // and set the input num so that the decoder can update the segment data
       
        case(sel) // toggle between the 4 digits
            2'd0: begin an <= 4'b1110; num <= dig1; end
            2'd1: begin an <= 4'b1101; num <= dig2; end
            2'd2: begin an <= 4'b1011; num <= dig3; end
            2'd3: begin an <= 4'b0111; num <= dig0; end
        endcase

        // if the digit is the selected one, and it's in the off phase, blank it
        blank_this_digit =
            adj_sw && blink &&
            ((sel_sw && (sel == 2'd0 || sel == 2'd1)) ||   // adjusting seconds
            (!sel_sw && (sel== 2'd2 || sel== 2'd3)));   // adjusting minutes

         
        seg <=  blank_this_digit ? 7'b111_1111 : seg_data;
        sel <= sel + 1;
    end

endmodule
    
