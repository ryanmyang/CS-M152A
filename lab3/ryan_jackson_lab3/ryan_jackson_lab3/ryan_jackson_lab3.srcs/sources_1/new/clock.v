`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/06/2025 01:04:44 PM
// Design Name: 
// Module Name: clock
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


module clock(
        input wire clk,
        output reg clk_1hz,
        output reg clk_2hz,
        output reg clk_500hz,
        output reg clk_4hz
    );
    
    integer HALF_PERIOD_1hz = 50000000;
    reg [25:0] counter_1hz  = 0;
    integer HALF_PERIOD_2hz = 25000000;
    reg [24:0] counter_2hz  = 0;
    integer HALF_PERIOD_4hz = 12500000;
    reg [24:0] counter_4hz  = 0;
    integer HALF_PERIOD_500hz = 100000; //current value: 500
    reg [18:0] counter_500hz  = 0;

    always @ (posedge clk) begin
         if(counter_1hz == HALF_PERIOD_1hz - 1) begin
            counter_1hz <= 0;
            clk_1hz <= ~clk_1hz;
         end
         else begin
            counter_1hz <= counter_1hz + 1;
         end
         
         if(counter_2hz == HALF_PERIOD_2hz - 1) begin
             counter_2hz <= 0;
             clk_2hz <= ~clk_2hz;
          end
          else begin
             counter_2hz <= counter_2hz + 1;
          end
          
          if(counter_4hz == HALF_PERIOD_4hz - 1) begin
               counter_4hz <= 0;
               clk_4hz <= ~clk_4hz;
            end
            else begin
               counter_4hz <= counter_4hz + 1;
            end
            
           if(counter_500hz == HALF_PERIOD_500hz - 1) begin
              counter_500hz <= 0;
              clk_500hz <= ~clk_500hz;
           end
           else begin
              counter_500hz <= counter_500hz + 1;
           end
         
         
     end
         
    
    
    
endmodule
