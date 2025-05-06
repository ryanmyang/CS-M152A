`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/06/2025 01:28:30 PM
// Design Name: 
// Module Name: stopwatch
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


module stopwatch(
    input wire clk_1hz,
    input wire rst,
    input wire pause,
    output reg [5:0] sec = 0,
    output reg [5:0] min = 0
    );
    
    always @(posedge clk_1hz) begin
        if(rst) begin
            sec <= 0;
            min <= 0;
        end else if (!pause) begin
            if (sec == 59) begin
                sec <= 0;
                if(min != 59) begin
                    min <= min + 1;
                end else begin
                    min <= 0;
                end
             end else begin
                sec <= sec + 1;
             end
        end
        
    end
    
    
    
endmodule
