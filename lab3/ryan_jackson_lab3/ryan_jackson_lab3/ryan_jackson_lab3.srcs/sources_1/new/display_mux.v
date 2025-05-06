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
    input wire clk_100hz,
    input [3:0] dig3,
    input [3:0] dig2,
    input [3:0] dig1,
    input [3:0] dig0,
    output reg [3:0]an,
    output reg [6:0] seg
    );
    
    reg [1:0] sel = 0; //active one
    reg [3:0] num; // current digit to display 
    wire [6:0] seg_data; // segment data for the current digit
    num_to_7seg decoder(.num(num), .seg(deg_data));
    always @(posedge clk_100hz) begin
        // basically every cycle, increment which digit is active
        // when each digit is active, set the anode to 0 and the rest to 1
        // and set the input num so that the decoder can update the segment data
        sel <= sel + 1;
        case(sel)
            2'd0: begin an = 4'1110; num = dig0; end
            2'd1: begin an = 4'1101; num = dig1; end
            2'd2: begin an = 4'1011; num = dig2; end
            2'd3: begin an = 4'0111; num = dig3; end
        endcase
        seg <= seg_data;
    end

endmodule
    
