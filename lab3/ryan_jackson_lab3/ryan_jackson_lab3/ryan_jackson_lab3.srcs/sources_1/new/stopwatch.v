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
    input wire clk_2hz,
    input wire rst,
    input wire enable,
    input wire adj,
    input wire sel,
      output reg [3:0] dig3,
      output reg [3:0] dig2,
      output reg [3:0] dig1,
      output reg [3:0] dig0
    );
    
    wire tick = adj ? clk_2hz : clk_1hz;
    always @(posedge tick or posedge rst) begin
      if(rst) begin
            dig3 <= 0;
            dig2 <= 0;
            dig1 <= 0;
            dig0 <= 0;
        end
        else if (adj) begin
            if (sel) begin           // --- adjust SECONDS
            if (dig0 == 9) begin
                dig0 <= 0;
                dig1 <= (dig1 == 5) ? 0 : dig1 + 1;
            end else begin
                dig0 <= dig0 + 1;
            end
        end else begin           // --- adjust MINUTES
            if (dig2 == 9) begin
                dig2 <= 0;
                dig3 <= (dig3 == 5) ? 0 : dig3 + 1;
            end else begin
                dig2 <= dig2 + 1;
           end
        end
             
        end
 
       else if (enable) begin
            if (dig0 == 9) begin
                dig0 <= 0;
                if(dig1 == 5) begin
                    dig1 <= 0;
                         if (dig2 == 9) begin
                           dig2 <= 0;
                           if(dig3 == 5) 
                               dig3 <= 0;
                           else 
                                dig3 <= dig3 + 1;
                         end else begin
                         dig2 <= dig2 + 1;
                         end
                end else begin
                    dig1 <= dig1 + 1;
                    end
               end else begin  
                dig0 <= dig0 + 1;
                end
             
        end
        
    end
    
endmodule
