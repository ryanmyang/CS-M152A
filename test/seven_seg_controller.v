`timescale 1ns / 1ps

module seven_seg_controller(
    input clk,                   // Display refresh clock (slower than main clock)
    input reset,
    input [15:0] display_value,  // 4 digits, each 4 bits
    output reg [6:0] seg,        // 7-segment display segments (active low)
    output reg [3:0] an,         // Display anodes (active low)
    output dp                    // Decimal point (not used, set high)
    );
    
    assign dp = 1'b1;  // Decimal point off
    
    reg [1:0] digit_select;      // Which digit to display
    reg [3:0] current_digit;     // Current digit value
    
    // Digit selection counter
    always @(posedge clk or posedge reset) begin
        if (reset)
            digit_select <= 2'b00;
        else
            digit_select <= digit_select + 1;
    end
    
    // Anode control (active low)
    always @(*) begin
        case (digit_select)
            2'b00: an = 4'b1110;  // Rightmost digit
            2'b01: an = 4'b1101;
            2'b10: an = 4'b1011;
            2'b11: an = 4'b0111;  // Leftmost digit
            default: an = 4'b1111;
        endcase
    end
    
    // Select current digit to display
    always @(*) begin
        case (digit_select)
            2'b00: current_digit = display_value[3:0];    // Rightmost
            2'b01: current_digit = display_value[7:4];
            2'b10: current_digit = display_value[11:8];
            2'b11: current_digit = display_value[15:12];  // Leftmost
            default: current_digit = 4'h0;
        endcase
    end
    
    // 7-segment decoder (active low outputs)
    always @(*) begin
        case (current_digit)
            4'h0: seg = 7'b1000000;  // 0
            4'h1: seg = 7'b1111001;  // 1
            4'h2: seg = 7'b0100100;  // 2
            4'h3: seg = 7'b0110000;  // 3
            4'h4: seg = 7'b0011001;  // 4
            4'h5: seg = 7'b0010010;  // 5
            4'h6: seg = 7'b0000010;  // 6
            4'h7: seg = 7'b1111000;  // 7
            4'h8: seg = 7'b0000000;  // 8
            4'h9: seg = 7'b0010000;  // 9
            4'hA: seg = 7'b0001000;  // A
            4'hB: seg = 7'b0000011;  // B
            4'hC: seg = 7'b1000110;  // C
            4'hD: seg = 7'b0100001;  // D
            4'hE: seg = 7'b0000110;  // E
            4'hF: seg = 7'b0001110;  // F
            default: seg = 7'b1111111;  // All segments off
        endcase
    end
    
endmodule 